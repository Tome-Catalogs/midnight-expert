---
name: midnight-verify:verify-sdk
description: 'SDK/TypeScript claim classification and method routing. Determines what kind of SDK claim is being verified and which verification method applies: type-checking (tsc --noEmit), devnet E2E testing, source inspection, or package checks. Handles both claims about the SDK API itself and verification of user code that uses the SDK. Loaded by the /midnight-verify:verify command alongside the hub skill.'
---

# SDK Claim Classification

This skill classifies SDK/TypeScript claims and determines which verification method to use. The /midnight-verify:verify command loads this alongside the `midnight-verify:verify-correctness` hub skill.

## Claim Type → Method Routing

When you receive an SDK-related claim, classify it using this table to determine which agent(s) to dispatch:

### Claims About the SDK API

| Claim Type | Example | Dispatch |
|---|---|---|
| API function exists | "deployContract is exported from contracts" | `midnight-verify:type-checker` |
| Function signature / return type | "deployContract returns DeployedContract" | `midnight-verify:type-checker` |
| Type/interface shape | "MidnightProviders has a walletProvider field" | `midnight-verify:type-checker` |
| Import path correctness | "import { deployContract } from '@midnight-ntwrk/midnight-js-contracts'" | `midnight-verify:type-checker` |
| Error class hierarchy | "CallTxFailedError extends TxFailedError" | `midnight-verify:type-checker` |
| Package exists / version | "@midnight-ntwrk/midnight-js-contracts is at version 4.1.1" | `devs:deps-maintenance` (fallback: run `npm view` directly) |
| Export count / package structure | "contracts package exports 91 symbols" | `midnight-verify:source-investigator` |
| Implementation details | "httpClientProofProvider retries 3 times with exponential backoff" | `midnight-verify:source-investigator` |
| Provider internal behavior | "LevelDB provider encrypts with AES-256-GCM" | `midnight-verify:source-investigator` |
| Deploy/call lifecycle behavior | "deployContract deploys and returns a contract address" | `midnight-verify:sdk-tester` |
| Transaction pipeline behavior | "submitCallTx proves, balances, submits, and waits" | `midnight-verify:sdk-tester` |
| State query behavior | "getPublicStates returns on-chain ledger state" | `midnight-verify:sdk-tester` |

### Claims About User Code That Uses the SDK

| Claim Type | Example | Dispatch |
|---|---|---|
| DApp code type-correctness | "This provider setup code is valid" | `midnight-verify:type-checker` |
| Witness implementation | "This witness correctly implements the contract interface" | `midnight-verify:witness-verifier` |
| Provider configuration | "This provider config connects to devnet correctly" | `midnight-verify:type-checker` + `midnight-verify:sdk-tester` |
| Import usage patterns | "This file's SDK imports are correct" | `midnight-verify:type-checker` |
| Transaction handling code | "This error handling catches CallTxFailedError" | `midnight-verify:type-checker` |
| E2E integration | "This deploy+call flow works against devnet" | `midnight-verify:sdk-tester` |
| File verification (`.ts` with SDK imports) | `/midnight-verify:verify app.ts` | `midnight-verify:type-checker` (types) + `midnight-verify:sdk-tester` (behavior, if devnet available) |
| Cross-domain (types + behavior) | "calling increment changes counter from 0 to 1" | `midnight-verify:type-checker` + `midnight-verify:sdk-tester` (concurrent) |

### Routing Rules

**When in doubt:**
- Types, signatures, imports, interfaces → `midnight-verify:type-checker`
- Runtime behavior, what happens when you call something → `midnight-verify:sdk-tester`
- Internal implementation, how something works under the hood → `midnight-verify:source-investigator`
- Package versions, existence → `devs:deps-maintenance` (or `npm view` fallback)

**When multiple methods apply, dispatch concurrently.** Type-checking and devnet testing are independent and can run in parallel.

## Hints from Existing Skills

Sub-agents may load these skills via Tome's `get_skill` MCP tool (not the `Skill` tool) for context. They are **hints only** — never cite skill content as evidence in the verdict.

- `midnight-dapp-dev:midnight-sdk` skill — provider setup, component overview
- `midnight-dapp-dev:dapp-connector` skill — wallet integration patterns
- `compact-core:compact-witness-ts` skill — witness implementation patterns
- `midnight-dapp-dev:midnight-sdk` skill — deployment patterns

Load only what's relevant to the specific claim.
