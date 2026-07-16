# Troubleshooting

| Symptom | Likely cause | First fix |
|---------|--------------|-----------|
| `STALE_UTXO` error on transfer | Concurrent spend used the same UTXO | Wait a few seconds, retry |
| `DUST_REQUIRED` error | Wallet has no DUST to pay fees | Run `examples/register-dust.ts`, wait for DUST to accrue |
| Sync never completes | Indexer or node unreachable | Invoke the `midnight-tooling:devnet` command (Tome MCP prompt, not the `Skill` tool) with `health`; check container status |
| `WebSocket is not defined` (Node) | Missing `ws` polyfill | Add the polyfill at the top of the script (see `network-config.md`) |
| `ERR_PACKAGE_PATH_NOT_EXPORTED` | Project is CJS, SDK is ESM | Set `"type": "module"` in `package.json` |
| `0` balance after faucet visit | Pasted shielded address into faucet | Use the UNSHIELDED address (`mn_addr_*`) |
| `WalletFacade.init` throws | Configuration shape mismatch or service unreachable | Verify each URL with `curl`; verify config matches `network-config.md` |
| `state.unshielded.balances[""]` returns `undefined` | Wrong key — empty string is not the native NIGHT key | Use `state.unshielded.balances[ledger.nativeToken().raw]` |
| Transaction submission rejected | Major SDK version drift, or ledger/protocol mismatch | Load `midnight-wallet:sdk-regression-check` via Tome's `get_skill` MCP tool (not the `Skill` tool) and run its smoke test; see release notes |
| Type errors after `npm install` | Major SDK version bump | Load `midnight-wallet:sdk-regression-check` via Tome's `get_skill` MCP tool (not the `Skill` tool) and run its drift check |
| Recipient never observes incoming NIGHT | Wrong recipient address; or wallet still syncing | Confirm address is unshielded; allow 30-90 seconds on devnet |

## When in doubt

Load the `midnight-wallet:sdk-regression-check` skill via Tome's
`get_skill` MCP tool (plugin `midnight-wallet`, name
`sdk-regression-check`) — not the `Skill` tool — and run it first. It
distinguishes between "the SDK changed" and "your environment is
broken" in under a minute.
