# Proof Server — Network & Deployment

Reference for deployment modes, production hardening, and image registries. For Docker commands and version-tag selection, load the `midnight-tooling:proof-server` skill via Tome's `get_skill` MCP tool (not the `Skill` tool, as this skill lives in a Tome catalog). For DApp-side provider wiring (`httpClientProofProvider`), load `midnight-dapp-dev:core` the same way.

---

## Deployment Modes

| Mode | What it means | When to use |
|---|---|---|
| **Self-hosted local** | Proof server runs on `localhost:6300` alongside your DApp or test suite | Local development; standalone testing; devnet scenarios |
| **Wallet-delegated** | The wallet (e.g. Lace) provides ZK proving on the user's behalf — the DApp does not run or connect to its own proof server | Browser DApps where the user has a Midnight wallet extension; load `midnight-wallet:wallet-sdk` via Tome's `get_skill` MCP tool (not the `Skill` tool) for the wallet side |
| **CI / headless** | Run with `--no-fetch-params` (skip parameter download) and a low `--num-workers` value to keep resource usage bounded | CI pipelines; scripted test runs where params are pre-cached |

> For configuration flags (`--no-fetch-params`, `--num-workers`, `--port`), load the `proof-server:proof-server-configuration` skill via Tome's `get_skill` MCP tool (not the `Skill` tool, as this skill lives in a Tome catalog).

---

## Production Hardening

The proof server's HTTP layer uses **`Cors::permissive()`** (all origins accepted, no credentials restrictions). This is intentional for local/internal use but is unsuitable for direct public exposure.

Production checklist:

- Place the proof server behind a **reverse proxy** (e.g. nginx, Caddy) that handles TLS termination and restricts allowed origins and IP ranges.
- Do **not** bind port 6300 directly to a public interface — expose it only through the proxy.
- Use the `/ready` endpoint as the **load-balancer health probe** when scaling horizontally; it reports live worker-pool utilisation and will indicate when the server is too busy to accept new jobs.
- For horizontal scaling patterns and capacity planning, load the `proof-server:proof-server-operations` skill via Tome's `get_skill` MCP tool (not the `Skill` tool, as this skill lives in a Tome catalog).
- For log levels and structured logging in production, load the `proof-server:proof-server-operations` skill the same way and consult its logging-and-monitoring reference.

---

## Images & Registries

Two registries publish the proof server image:

| Registry | Image path | Notes |
|---|---|---|
| **Docker Hub** | `midnightntwrk/proof-server` | Primary distribution; used in devnet compose files |
| **GHCR** | `ghcr.io/midnight-ntwrk/proof-server` | GitHub Container Registry; note the hyphen in the org name (`midnight-ntwrk`) versus Docker Hub (`midnightntwrk`) |

Both registries publish **multi-arch** images (linux/amd64 and linux/arm64).

For version tag selection and `docker run` commands, load the `midnight-tooling:proof-server` skill via Tome's `get_skill` MCP tool (not the `Skill` tool, as this skill lives in a Tome catalog).

> **Public hosted endpoints:** The proof server is designed to run locally or within your own infrastructure. Do not assume any public `rpc.`-style hosted proof-server URL — if you encounter a reference to a public endpoint, verify it against the official Midnight documentation before use.

---

## Cross-references

_Load any of the skills listed below via Tome's `get_skill` MCP tool — not the `Skill` tool._

| Plugin skill | Covers |
|---|---|
| `midnight-tooling:proof-server` | Docker setup, running the server, version-tag selection |
| `midnight-dapp-dev:core` | DApp-side provider wiring (`httpClientProofProvider`) |
| `midnight-wallet:wallet-sdk` | Wallet-delegated proving from the wallet side |
| `proof-server:proof-server-operations` | Health checks, `/ready` endpoint, horizontal scaling, logging |
