---
name: midnight-verify:verify-ledger
description: 'Ledger/protocol claim classification and method routing. Determines what kind of ledger claim is being verified and which verification methods apply: source investigation (primary), type-checking (pre-flight for TypeScript API), compilation/execution (secondary for testable claims), or ledger-v8 execution (secondary for API behavioral claims). Handles claims about transaction structure, token mechanics (Night/Zswap/Dust), cost model, on-chain VM, contract execution, cryptographic primitives, well-formedness rules, and the @midnight-ntwrk/ledger-v8 TypeScript API. Loaded by the /midnight-verify:verify command alongside the hub skill.'
---

# Ledger/Protocol Claim Classification

This skill classifies ledger and protocol claims and determines which verification method to use. The /midnight-verify:verify command loads this alongside the `midnight-verify:verify-correctness` hub skill.

## Verification Flow

Ledger claims have a richer verification hierarchy than other domains because the ledger crates produce the compiled output that the contract-writer and zkir-checker already work with.

1. **Type-check (pre-flight)** — for TypeScript API claims only. Dispatch `midnight-verify:type-checker` against the existing sdk-workspace (ledger-v8 is already installed). Pre-flight only, never a standalone verdict.
2. **Source investigation (primary)** — always runs for protocol claims. Dispatch `midnight-verify:source-investigator`, instructing it to load the `midnight-verify:verify-by-ledger-source` skill via Tome's `get_skill` MCP tool (not the `Skill` tool) for Rust crate-level routing.
3. **Compilation/execution (secondary)** — for claims testable via Compact contracts. Dispatch `midnight-verify:contract-writer` (compile + execute, extract ledger-level evidence) or `midnight-verify:zkir-checker` (inspect compiled circuits).
4. **Ledger-v8 execution (secondary)** — for claims about TypeScript API behavioral output. Write a script that calls ledger-v8 functions and observes output.

## Claim Type → Method Routing

### Claims About Protocol Structure

| Claim Type | Example | Pre-flight | Primary | Secondary |
|---|---|---|---|---|
| Transaction format | "Transactions contain intents, offers, and binding randomness" | — | `midnight-verify:source-investigator` | — |
| Segment ordering | "Segment 0 is guaranteed, executes first" | — | `midnight-verify:source-investigator` | `midnight-verify:contract-writer` (negative test) |
| Causal precedence | "Contract A calling B means A causally precedes B" | — | `midnight-verify:source-investigator` | — |
| Replay protection | "Intent hashes stored in TimeFilterMap" | — | `midnight-verify:source-investigator` | — |
| Well-formedness | "Disjoint check prevents input/output overlap" | — | `midnight-verify:source-investigator` | `midnight-verify:contract-writer` (build invalid tx) |
| Proof staging | "UnprovenTransaction transitions to Proven via prove()" | — | `midnight-verify:source-investigator` | ledger-v8 execution |

### Claims About Token Mechanics

| Claim Type | Example | Pre-flight | Primary | Secondary |
|---|---|---|---|---|
| Night UTXO | "UTXO uniqueness from (intent_hash, output_no)" | — | `midnight-verify:source-investigator` | — |
| Zswap commitments | "CoinCommitment = Hash<(CoinInfo, CoinPublicKey)>" | — | `midnight-verify:source-investigator` | ledger-v8 execution (call coinCommitment) |
| Zswap nullifiers | "CoinNullifier = Hash<(CoinInfo, CoinSecretKey)>" | — | `midnight-verify:source-investigator` | ledger-v8 execution (call coinNullifier) |
| Zswap transients | "Transients use ephemeral single-leaf Merkle tree" | — | `midnight-verify:source-investigator` | — |
| Dust generation | "Dust generates proportional to backing Night value" | — | `midnight-verify:source-investigator` | — |
| Dust spending | "Dust spend requires ZK proof of generation chain" | — | `midnight-verify:source-investigator` | — |
| Token types | "NIGHT is TokenType::Unshielded with raw [0u8; 32]" | — | `midnight-verify:source-investigator` | ledger-v8 execution (call nativeToken) |

### Claims About Cost Model

| Claim Type | Example | Pre-flight | Primary | Secondary |
|---|---|---|---|---|
| Cost dimensions | "SyntheticCost has 5 dimensions: read, compute, block, write, churn" | — | `midnight-verify:source-investigator` | — |
| Fee formula | "Fee = max(read, compute, block) + write + churn" | — | `midnight-verify:source-investigator` | `midnight-verify:contract-writer` (compile, measure cost) |
| Block limits | "Block usage limit is 200,000 bytes" | — | `midnight-verify:source-investigator` | — |
| Price adjustment | "Per-dimension price targets 50% block fullness" | — | `midnight-verify:source-investigator` | — |
| Guaranteed limits | "Guaranteed section has separate cost bounds" | — | `midnight-verify:source-investigator` | — |

### Claims About On-Chain VM

| Claim Type | Example | Pre-flight | Primary | Secondary |
|---|---|---|---|---|
| Opcode semantics | "idx loads from Map by key" | — | `midnight-verify:source-investigator` | `midnight-verify:zkir-checker` (inspect compiled) |
| StateValue types | "5 types: Null, Cell, Map, Array, BoundedMerkleTree" | — | `midnight-verify:source-investigator` | — |
| Stack machine | "VM is a stack machine, always exactly 1 item initially" | — | `midnight-verify:source-investigator` | — |
| Cached reads | "idxc requires value to be cached in memory" | — | `midnight-verify:source-investigator` | — |

### Claims About Contract Execution

| Claim Type | Example | Pre-flight | Primary | Secondary |
|---|---|---|---|---|
| Contract address | "ContractAddress = Hash<ContractDeploy>" | — | `midnight-verify:source-investigator` | — |
| Effects system | "Effects declare claimed nullifiers, commitments, calls" | — | `midnight-verify:source-investigator` | `midnight-verify:contract-writer` (compile + execute) |
| Caller determination | "Caller is calling contract, then single UTXO owner, then None" | — | `midnight-verify:source-investigator` | — |
| Transcripts | "Guaranteed transcript executes before fees are taken" | — | `midnight-verify:source-investigator` | — |

### Claims About Cryptographic Primitives

| Claim Type | Example | Pre-flight | Primary | Secondary |
|---|---|---|---|---|
| Pedersen commitments | "Value commitment = g*r + h*v where h = hash(type, segment)" | — | `midnight-verify:source-investigator` | — |
| Fiat-Shamir binding | "Binding uses challenge c = hash(ErasedIntent, g*r, g*s)" | — | `midnight-verify:source-investigator` | — |
| Signatures | "Schnorr over Secp256k1 per BIP 340" | — | `midnight-verify:source-investigator` | — |
| Hashing | "field::hash uses Poseidon" | — | `midnight-verify:source-investigator` | — |
| Merkle trees | "Commitment tree uses persistent Merkle tree" | — | `midnight-verify:source-investigator` | — |

### Claims About Ledger TypeScript API

| Claim Type | Example | Pre-flight | Primary | Secondary |
|---|---|---|---|---|
| Type/export existence | "ledger-v8 exports Transaction class" | `midnight-verify:type-checker` | `midnight-verify:source-investigator` | — |
| Function signature | "coinCommitment takes (coin, coinPublicKey)" | `midnight-verify:type-checker` | `midnight-verify:source-investigator` | — |
| Function behavior | "nativeToken() returns the NIGHT raw token type" | `midnight-verify:type-checker` | `midnight-verify:source-investigator` | ledger-v8 execution |
| Class API | "ZswapLocalState has spend() method" | `midnight-verify:type-checker` | `midnight-verify:source-investigator` | — |
| CostModel API | "CostModel.initialCostModel() returns default fee config" | `midnight-verify:type-checker` | `midnight-verify:source-investigator` | ledger-v8 execution |

### Claims About Formal Properties

| Claim Type | Example | Pre-flight | Primary | Secondary |
|---|---|---|---|---|
| Balance preservation | "Total funds preserved except mints, dust, and treasury" | — | `midnight-verify:source-investigator` | — |
| Transaction binding | "Assembled transaction cannot be disassembled" | — | `midnight-verify:source-investigator` | — |
| Infragility | "Defensively-created tx survives malicious merge" | — | `midnight-verify:source-investigator` | — |
| Causality | "Contract call A → B implies A success ⟹ B success" | — | `midnight-verify:source-investigator` | — |
| Self-determination | "User cannot spend another user's funds" | — | `midnight-verify:source-investigator` | — |

### Routing Rules

**When in doubt:**
- Protocol structure, token mechanics, crypto primitives → `midnight-verify:source-investigator` (Rust source is authoritative)
- TypeScript API surface → `midnight-verify:type-checker` pre-flight + `midnight-verify:source-investigator` (trace WASM binding to Rust)
- Testable behavior (cost, well-formedness, token operations) → `midnight-verify:source-investigator` + `midnight-verify:contract-writer` or ledger-v8 execution as secondary
- Formal properties → `midnight-verify:source-investigator` only (these are about the proof structure in code)

**Source investigation is always primary.** Secondary methods (compilation, execution) provide corroborating evidence but are not required for a verdict.

## Hints from Existing Skills

Sub-agents may load these skills via Tome's `get_skill` MCP tool (not the `Skill` tool) for context. They are **hints only** — never cite skill content as evidence.

- `compact-core:compact-standard-library` skill — stdlib functions that map to ledger primitives
- `midnight-tooling:compact-cli` skill — how Compact compiles to ZKIR (relevant for VM claims)
- `midnight-tooling:compact-cli` skill — compiler behavior and flags
