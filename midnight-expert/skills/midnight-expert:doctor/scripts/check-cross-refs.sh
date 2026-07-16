#!/usr/bin/env bash
set -u

emit() {
  local name="$1"
  local status="$2"
  local detail="$3"
  detail="$(printf '%s' "$detail" | tr '\n' ';' | sed 's/  */ /g; s/; */; /g; s/; $//')"
  printf '%s | %s | %s\n' "$name" "$status" "$detail"
}

# Under Tome, intra-catalog references (compact-core -> midnight-tooling, etc.)
# are guaranteed present whenever the catalog is installed, and Tome's own
# indexing/lint surfaces any broken entry reference. The check that still adds
# value is whether the EXTERNAL cross-catalog dependencies are enabled.
if ! command -v tome >/dev/null 2>&1; then
  emit "cross-refs" "warn" "tome not found on PATH — cannot validate cross-plugin dependencies"
  exit 0
fi

ALL_JSON="$(tome plugin list --json 2>/dev/null)"
if [ -z "$ALL_JSON" ] || ! command -v python3 >/dev/null 2>&1; then
  emit "cross-refs" "info" "cannot enumerate plugins via Tome (need 'tome' and python3) — skipping cross-plugin dependency checks"
  exit 0
fi

# External cross-catalog dependencies referenced by midnight-expert plugins.
# Format: catalog:plugin|why it is needed
DEPS=(
  "agent-foundry:devs|used by midnight-verify (deps-maintenance agent) and compact-core (code-review / typescript / security skills)"
)

fail=0
for dep in "${DEPS[@]}"; do
  target="${dep%%|*}"
  why="${dep#*|}"
  dep_catalog="${target%%:*}"
  dep_plugin="${target##*:}"

  status="$(printf '%s\n' "$ALL_JSON" | python3 -c "
import json, sys
cat, plug = sys.argv[1], sys.argv[2]
res = 'missing'
for line in sys.stdin:
    line = line.strip()
    if not line:
        continue
    try:
        d = json.loads(line)
    except Exception:
        continue
    pid = d.get('id', {})
    if pid.get('catalog') == cat and pid.get('plugin') == plug:
        res = d.get('status', 'unknown')
        break
print(res)
" "$dep_catalog" "$dep_plugin")"

  case "$status" in
    enabled)  emit "dep: $target" "pass" "enabled ($why)" ;;
    disabled) emit "dep: $target" "warn" "available but not enabled — run 'tome plugin enable $dep_plugin' ($why)"; fail=1 ;;
    missing)  emit "dep: $target" "warn" "not found in any registered catalog — add the '$dep_catalog' catalog ($why)"; fail=1 ;;
    *)        emit "dep: $target" "info" "status: $status ($why)" ;;
  esac
done

if [ "$fail" -eq 0 ]; then
  emit "ALL_REFS_PASS" "pass" "all external cross-plugin dependencies satisfied"
fi
