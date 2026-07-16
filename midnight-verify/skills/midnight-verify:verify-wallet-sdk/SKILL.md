---
name: midnight-verify:verify-wallet-sdk
description: 'Wallet SDK claim classification and method routing. Determines what kind of wallet SDK claim is being verified and which verification methods apply: type-checking (pre-flight only), source investigation (primary), or devnet E2E (fallback). Handles claims about @midnight-ntwrk/wallet-sdk-* packages, WalletFacade, WalletBuilder, the DApp Connector API, HD derivation, Bech32m addresses, branded types, and the three-wallet architecture. Loaded by the /midnight-verify:verify command alongside the hub skill.'
---

# Wallet SDK Claim Classification

This skill classifies wallet SDK claims and determines which verification method to use. The /midnight-verify:verify command loads this alongside the `midnight-verify:verify-correctness` hub skill.

## Verification Flow

Every wallet SDK claim follows the same three-step flow:

1. **Type-check (pre-flight)** — dispatch `midnight-verify:type-checker` in wallet-sdk-workspace mode. Fails fast if the claim is fundamentally broken. Type-checking alone NEVER produces a verdict for wallet SDK claims.
2. **Source investigation (primary)** — always runs. Dispatch `midnight-verify:source-investigator`, instructing it to load the `midnight-verify:verify-by-wallet-source` skill via Tome's `get_skill` MCP tool (not the `Skill` tool). This is the primary evidence source for all wallet SDK verdicts.
3. **Devnet E2E (fallback)** — dispatch `midnight-verify:sdk-tester` in wallet-devnet mode ONLY if source investigation returns Inconclusive.

## Claim Type → Method Routing

When you receive a wallet SDK claim, classify it using this table:

### Claims About SDK Package API

| Claim Type | Example | Pre-flight | Primary | Fallback |
|---|---|---|---|---|
| Package/type existence | "WalletFacade exports balanceFinalizedTransaction" | `midnight-verify:type-checker` | `midnight-verify:source-investigator` | — |
| Function signature | "submitTransaction returns Observable\<SubmissionEvent\>" | `midnight-verify:type-checker` | `midnight-verify:source-investigator` | — |
| Interface shape | "ShieldedAddress has coinPublicKey and encryptionPublicKey" | `midnight-verify:type-checker` | `midnight-verify:source-investigator` | — |
| Branded type structure | "ProtocolVersion is a branded bigint" | `midnight-verify:type-checker` | `midnight-verify:source-investigator` | — |
| Transaction lifecycle | "SubmissionEvent goes Submitted → InBlock → Finalized" | `midnight-verify:type-checker` | `midnight-verify:source-investigator` | — |

### Claims About Wallet Architecture

| Claim Type | Example | Pre-flight | Primary | Fallback |
|---|---|---|---|---|
| HD derivation paths | "Role 2 is Dust, path m/44'/2400'/0'/2/0" | — | `midnight-verify:source-investigator` | — |
| Address encoding | "Bech32m prefix for shielded is mn_shield-addr" | — | `midnight-verify:source-investigator` | — |
| Three-token architecture | "Dust balance is time-dependent" | — | `midnight-verify:source-investigator` | — |
| Variant/runtime behavior | "WalletRuntime migrates state between protocol versions" | — | `midnight-verify:source-investigator` | `midnight-verify:sdk-tester` |
| Indexer/node integration | "IndexerClient retries 3 times on 502-504" | — | `midnight-verify:source-investigator` | — |

### Claims About DApp Connector API

| Claim Type | Example | Pre-flight | Primary | Fallback |
|---|---|---|---|---|
| Connector API methods | "ConnectedAPI.makeTransfer creates a shielded transfer" | `midnight-verify:type-checker` | `midnight-verify:source-investigator` | `midnight-verify:sdk-tester` |
| Connector error handling | "PermissionRejected is permanent per session" | — | `midnight-verify:source-investigator` | — |
| Connector types | "DesiredOutput has kind, type, value, recipient fields" | `midnight-verify:type-checker` | `midnight-verify:source-investigator` | — |

### Claims About Behavioral Outcomes

| Claim Type | Example | Pre-flight | Primary | Fallback |
|---|---|---|---|---|
| Facade lifecycle | "WalletFacade.init syncs all three wallets" | — | `midnight-verify:source-investigator` | `midnight-verify:sdk-tester` |
| Proving behavior | "WasmProver uses web-worker for background proving" | — | `midnight-verify:source-investigator` | — |
| Submission behavior | "PolkadotNodeClient auto-disconnects after metadata fetch" | — | `midnight-verify:source-investigator` | — |

### Routing Rules

**When in doubt:**
- API surface (types, exports, signatures) → `midnight-verify:type-checker` pre-flight + `midnight-verify:source-investigator`
- Architecture or protocol design → `midnight-verify:source-investigator` only
- Runtime behavior → `midnight-verify:source-investigator`, with `midnight-verify:sdk-tester` fallback if Inconclusive

**Type-checking is NEVER sufficient alone.** It is a fast pre-flight gate. Every wallet SDK claim must be resolved by source investigation (or devnet E2E as a last resort).

## Hints from Existing Skills

Sub-agents may load these skills via Tome's `get_skill` MCP tool (not the `Skill` tool) for context. They are **hints only** — never cite skill content as evidence in the verdict.

- `midnight-dapp-dev:midnight-sdk` skill — provider setup, SDK component overview
- `midnight-dapp-dev:dapp-connector` skill — wallet integration patterns
- `compact-core:compact-witness-ts` skill — witness implementation patterns (if claim spans wallet + witness)
- `midnight-wallet:wallet-sdk` skill — comprehensive wallet SDK package reference, API surface, construction patterns

Load only what's relevant to the specific claim.
