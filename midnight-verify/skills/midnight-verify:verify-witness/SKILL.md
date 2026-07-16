---
name: midnight-verify:verify-witness
description: Witness claim classification and method routing. Determines what kind of witness claim is being verified and dispatches to the witness-verifier. Handles claims about witness type correctness, name matching, return tuple shape, type mappings, behavioral correctness, private state patterns, and two-file verification. Loaded by the /midnight-verify:verify command alongside the hub skill.
---

# Witness Claim Classification

This skill classifies witness-related claims and determines which agent(s) to dispatch. The /midnight-verify:verify command loads this alongside the `midnight-verify:verify-correctness` hub skill.

## Claim Type → Method Routing

When you receive a witness-related claim, classify it using this table:

### Claims About the Contract-Witness Interface

| Claim Type | Example | Dispatch |
|---|---|---|
| Witness type correctness | "This witness correctly implements the contract interface" | `midnight-verify:witness-verifier` |
| Witness name matching | "The witness names match the contract declarations" | `midnight-verify:witness-verifier` |
| Witness return type | "This witness returns the correct [PrivateState, ReturnValue] tuple" | `midnight-verify:witness-verifier` |
| Type mapping correctness | "The Field parameters map to bigint in the witness" | `midnight-verify:witness-verifier` |
| WitnessContext usage | "This witness correctly uses the ledger from WitnessContext" | `midnight-verify:witness-verifier` |
| Private state patterns | "This witness doesn't mutate private state in place" | `midnight-verify:witness-verifier` |

### Claims About Witness Behavior

| Claim Type | Example | Dispatch |
|---|---|---|
| Behavioral correctness | "This contract + witness combination produces valid results" | `midnight-verify:witness-verifier` |
| Two-file verification | `/midnight-verify:verify contracts/counter.compact src/witnesses.ts` | `midnight-verify:witness-verifier` (both files) |
| Witness + devnet E2E | "This witness works correctly when deployed" | `midnight-verify:witness-verifier` + `midnight-verify:sdk-tester` (concurrent) |

### Cross-Domain Claims

| Claim Type | Example | Dispatch |
|---|---|---|
| Witness + ZK proof | "This contract + witness produces a valid ZK proof" | `midnight-verify:witness-verifier` first, then `midnight-verify:zkir-checker` (sequential — witness-verifier passes build output path) |

### Routing Rules

**When in doubt:**
- Claims about the contract-witness interface → `midnight-verify:witness-verifier`
- Claims about just the TypeScript types (no contract involved) → `midnight-verify:type-checker` (existing SDK path)
- Claims about just the Compact declarations (no witness implementation) → `midnight-verify:contract-writer` (existing Compact path)

**For Witness + ZKIR claims:** dispatch `midnight-verify:witness-verifier` first (it compiles and verifies), then pass the build output path to `midnight-verify:zkir-checker`. These are sequential, not concurrent, because the zkir-checker depends on the compiled artifacts.

## Hints from Existing Skills

The `midnight-verify:witness-verifier` may load these skills via Tome's `get_skill` MCP tool (not the `Skill` tool) for context. They are **hints only** — never cite skill content as evidence.

- `compact-core:compact-witness-ts` skill — witness implementation patterns, WitnessContext API, type mappings
- `compact-core:compact-structure` skill — witness declarations, disclosure rules
- `compact-core:compact-review` skill — witness consistency review checklist
