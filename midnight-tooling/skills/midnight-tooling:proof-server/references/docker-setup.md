# Docker Setup

For all Docker prerequisites, installation, resource requirements, and troubleshooting, load the `midnight-tooling:devnet` skill via Tome's `get_skill` MCP tool (plugin `midnight-tooling`, name `devnet`) — do not use the `Skill` tool, as this skill lives in a Tome catalog — and see its Docker setup reference: `skills/devnet/references/docker-setup.md`.

That guide covers everything needed for both devnet usage and standalone proof-server usage.

## Standalone Proof Server

If running a proof server outside the devnet (e.g., connecting to testnet/mainnet), use:

```bash
docker run -d --name midnight-proof-server -p 6300:6300 midnightntwrk/proof-server:<tag> -- midnight-proof-server -v
```

See the main Docker setup reference for Docker installation and daemon troubleshooting.
