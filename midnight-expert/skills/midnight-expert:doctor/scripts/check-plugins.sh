#!/usr/bin/env bash
set -u

emit() {
  local name="$1"
  local status="$2"
  local detail="$3"
  detail="$(printf '%s' "$detail" | tr '\n' ';' | sed 's/  */ /g; s/; */; /g; s/; $//')"
  printf '%s | %s | %s\n' "$name" "$status" "$detail"
}

CATALOG="midnight-expert"

# Tome is the source of truth for what is installed/enabled — it works across
# every harness Tome targets, unlike the Claude-Code-only ~/.claude layout.
if ! command -v tome >/dev/null 2>&1; then
  emit "Tome CLI" "warn" "tome not found on PATH — cannot report plugin status. Install Tome to enable this check."
  exit 0
fi

LIST_JSON="$(tome plugin list --catalog "$CATALOG" --json 2>/dev/null)"

if [ -z "$LIST_JSON" ]; then
  emit "Catalog registration" "info" "catalog '$CATALOG' is not registered/enabled in the current Tome scope — add it with 'tome catalog add <repo>', then 'tome plugin enable <name>'"
  exit 0
fi

if ! command -v python3 >/dev/null 2>&1; then
  emit "Plugin status" "info" "python3 not available — cannot parse 'tome plugin list' output for per-plugin detail"
  exit 0
fi

# The plugin set is derived dynamically from what Tome reports for the catalog,
# so it never drifts from the catalog's actual contents.
any_enabled=0
while IFS=$'\t' read -r plugin version status; do
  [ -z "$plugin" ] && continue
  case "$status" in
    enabled)  emit "$plugin" "pass" "v${version} (enabled)"; any_enabled=1 ;;
    disabled) emit "$plugin" "info" "v${version} (available, not enabled — enable only what you need)" ;;
    *)        emit "$plugin" "info" "v${version} (${status})" ;;
  esac
done < <(printf '%s\n' "$LIST_JSON" | python3 -c "
import json, sys
for line in sys.stdin:
    line = line.strip()
    if not line:
        continue
    try:
        d = json.loads(line)
    except Exception:
        continue
    pid = d.get('id', {})
    print('%s\t%s\t%s' % (pid.get('plugin', ''), d.get('version', ''), d.get('status', '')))
")

if [ "$any_enabled" -eq 1 ]; then
  emit "ALL_PLUGINS_PASS" "pass" "midnight-expert plugins detected via Tome"
fi
