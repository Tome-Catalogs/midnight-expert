# midnight-expert

**midnight-expert** is a [Tome](https://github.com/devrelaicom/tome) catalog of plugins for developers building on the [Midnight Network](https://midnight.network/). The plugins help you write and review Compact smart contracts, scaffold and wire up DApp frontends, mechanically verify claims about your code and the SDK, manage the local toolchain and devnet, dig into the node / indexer / proof-server internals, and look up whichever error code just spoiled your afternoon — from inside whichever agent coding harness you use (Claude Code, Cursor, Zed, Copilot, Gemini CLI, OpenCode, and more), without leaving your editor or stitching together half a dozen browser tabs.

This project extends the Midnight Network with additional developer tooling.

**[midnightntwrk.expert](https://midnightntwrk.expert/)** — documentation, guides, and resources for Midnight developers.

## At a glance

- **15** Plugins
- **97** Skills / Slash commands
- **17** Agents
- **~46,500** Lines of reference documentation
- **~30,000** Lines of example code

## Install

> [!IMPORTANT]
> **Platform support: macOS and Linux.** midnight-expert is developed and tested on macOS and Linux only. Native Windows (PowerShell, CMD, Git Bash/MSYS2, Cygwin) is **untested and unsupported** — the plugins' hooks and shell scripts assume a POSIX environment and are known to misbehave there (for example, a bare `compact` resolving to the unrelated Windows `compact.exe`, and path/encoding handling breaking under Git Bash).
>
> **Windows users should run everything inside [WSL](https://learn.microsoft.com/windows/wsl/) (WSL2 recommended).** Install a Linux distribution, then install Node.js, the Compact toolchain, your harness, and Tome *inside* the WSL environment — not on the Windows host. Under WSL the plugins behave exactly as they do on native Linux.

This is a **Tome catalog**, so you add it once with [Tome](https://github.com/devrelaicom/tome) and use it from every coding harness Tome supports — no per-harness setup, no marketplace-specific tooling.

### Add the catalog and enable plugins

```bash
# 1. Register the catalog (owner/repo shorthand, or a full git URL)
tome catalog add Tome-Catalogs/midnight-expert

# 2. Enable the plugins you want
tome plugin enable compact-core
tome plugin enable midnight-verify
tome plugin enable midnight-tooling

# 3. Wire the enabled plugins into your harness
tome harness use <your-harness>
```

Restart your harness (or start a new session) so it picks up the new skills, commands, and agents. New to Tome? See the [Tome documentation](https://github.com/devrelaicom/tome).

> [!TIP]
> The catalog is added straight from GitHub, so you are always on the latest published version. Pull newer releases at any time with `tome catalog update`.

## Plugins

Enable any plugin with `tome plugin enable <plugin>` once the catalog is added.

### Smart Contract Development

<table>
  <thead>
    <tr><th>Plugin</th><th>Description</th></tr>
  </thead>
  <tbody>
  <tr>
    <td><strong><a href="compact-core/">compact-core</a></strong></td>
    <td>Core knowledge for writing Compact — contract structure, data types, ledger declarations, circuits, witnesses, privacy/disclosure rules, tokens, circuit costs, debugging, and code review.<pre lang="bash">tome plugin enable compact-core</pre></td>
  </tr>
  <tr>
    <td><strong><a href="compact-examples/">compact-examples</a></strong></td>
    <td>Compilable Compact examples — beginner contracts, reusable modules, token implementations, and full applications with witnesses and tests.<pre lang="bash">tome plugin enable compact-examples</pre></td>
  </tr>
  <tr>
    <td><strong><a href="compact-cli-dev/">compact-cli-dev</a></strong></td>
    <td>Scaffold and develop Oclif CLIs for Compact contracts — wallet management, contract deployment, devnet control, plus an agent for ongoing CLI work.<pre lang="bash">tome plugin enable compact-cli-dev</pre></td>
  </tr>
  </tbody>
</table>

### DApp Development

<table>
  <thead>
    <tr><th>Plugin</th><th>Description</th></tr>
  </thead>
  <tbody>
  <tr>
    <td><strong><a href="midnight-dapp-dev/">midnight-dapp-dev</a></strong></td>
    <td>Scaffold and build Midnight DApp frontends — Vite + React 19 + shadcn + Tailwind v4 templates, wallet integration, provider architecture, and a development agent for ongoing UI work.<pre lang="bash">tome plugin enable midnight-dapp-dev</pre></td>
  </tr>
  </tbody>
</table>

### Testing & Code Quality

<table>
  <thead>
    <tr><th>Plugin</th><th>Description</th></tr>
  </thead>
  <tbody>
  <tr>
    <td><strong><a href="midnight-cq/">midnight-cq</a></strong></td>
    <td>Code quality tooling for Midnight projects — linting, formatting, type checking, contract/DApp/ledger/wallet testing, Git hooks, and CI workflows.<pre lang="bash">tome plugin enable midnight-cq</pre></td>
  </tr>
  <tr>
    <td><strong><a href="midnight-verify/">midnight-verify</a></strong></td>
    <td>Verification framework for Midnight claims — compile + execute Compact, type-check SDK code, run ZKIR through the WASM checker, cross-check witness implementations, and inspect compiler/ledger/wallet source. Multi-agent pipeline behind the <code>midnight-verify:verify</code> command.<pre lang="bash">tome plugin enable midnight-verify</pre></td>
  </tr>
  <tr>
    <td><strong><a href="midnight-fact-check/">midnight-fact-check</a></strong></td>
    <td>Fact-checking pipeline for Midnight content — extracts testable claims from markdown, code, PDFs, URLs or GitHub repos, classifies them by domain, verifies each via <code>midnight-verify</code>, and produces structured reports.<pre lang="bash">tome plugin enable midnight-fact-check</pre></td>
  </tr>
  </tbody>
</table>

### Toolchain & Infrastructure

<table>
  <thead>
    <tr><th>Plugin</th><th>Description</th></tr>
  </thead>
  <tbody>
  <tr>
    <td><strong><a href="midnight-tooling/">midnight-tooling</a></strong></td>
    <td>Install, configure, and manage the Compact CLI, the local devnet (node, indexer, proof server), compiler version switching, diagnostics, and ecosystem release notes.<pre lang="bash">tome plugin enable midnight-tooling</pre></td>
  </tr>
  <tr>
    <td><strong><a href="midnight-wallet/">midnight-wallet</a></strong></td>
    <td>Wallet SDK reference, test-wallet management patterns, and SDK regression checking for Midnight Network development.<pre lang="bash">tome plugin enable midnight-wallet</pre></td>
  </tr>
  <tr>
    <td><strong><a href="midnight-status-codes/">midnight-status-codes</a></strong></td>
    <td>Catalog and lookup for every Midnight error code, status code, and tagged error across the node, ledger, indexer, wallet, SDK, compiler, proof server, and DApp connector.<pre lang="bash">tome plugin enable midnight-status-codes</pre></td>
  </tr>
  </tbody>
</table>

### Knowledge & Reference

<table>
  <thead>
    <tr><th>Plugin</th><th>Description</th></tr>
  </thead>
  <tbody>
  <tr>
    <td><strong><a href="core-concepts/">core-concepts</a></strong></td>
    <td>Conceptual foundations for the Midnight Network — architecture, data models, privacy patterns, protocols (Kachina, Zswap), tokenomics, and zero-knowledge proofs.<pre lang="bash">tome plugin enable core-concepts</pre></td>
  </tr>
  <tr>
    <td><strong><a href="midnight-node/">midnight-node</a></strong></td>
    <td>Technical reference for the Midnight node — Substrate-based architecture, runtime pallets, RPC interface, configuration, operations, and governance.<pre lang="bash">tome plugin enable midnight-node</pre></td>
  </tr>
  <tr>
    <td><strong><a href="midnight-indexer/">midnight-indexer</a></strong></td>
    <td>Technical reference for the Midnight indexer — architecture, GraphQL API, data model, and operational guidance for querying on-chain state.<pre lang="bash">tome plugin enable midnight-indexer</pre></td>
  </tr>
  <tr>
    <td><strong><a href="proof-server/">proof-server</a></strong></td>
    <td>Deep technical reference for the Midnight proof server — internal architecture, complete API reference, configuration tuning, and operational monitoring.<pre lang="bash">tome plugin enable proof-server</pre></td>
  </tr>
  </tbody>
</table>

### Meta

<table>
  <thead>
    <tr><th>Plugin</th><th>Description</th></tr>
  </thead>
  <tbody>
  <tr>
    <td><strong><a href="midnight-expert/">midnight-expert</a></strong></td>
    <td>Ecosystem diagnostics — health-checks your Compact toolchain, plugin enablement (via the Tome CLI), MCP server connectivity, external CLI tools, and cross-plugin dependencies in one report.<pre lang="bash">tome plugin enable midnight-expert</pre></td>
  </tr>
  </tbody>
</table>

## Example Prompts

Most of the time you don't need to remember a command — once a plugin is enabled, its skills activate based on what you're asking for. A few starting points:

- "Is my local Midnight proof server healthy, and is the indexer caught up to the node?"
- "Review `contracts/Report.compact` for potential privacy leaks before I push."
- "Why is my proof generation failing with status code `0x4b`?"
- "Scaffold a Vite + React DApp wired to my counter contract and connect it to the Lace wallet."
- "Fact-check this Midnight blog post against the current SDK and tell me what's drifted."
- "Set up `alice`, `bob`, and `charlie` as funded test wallets on the local devnet, with DUST registered for each."
- "Compile `MyToken.compact`, simulate a mint + transfer + burn, and show me the resulting ledger state."
- "Write a Compact contract for a sealed-bid voting system and walk me through the disclosure rules."
- "I'm getting `Implicit disclosure of witness value` — what does that mean and how do I fix it?"

Your harness exposes each plugin's commands as slash commands or MCP prompts, so you can also invoke a specific workflow directly:

```
midnight-verify:verify "Compact tuples are 0-indexed"
midnight-tooling:devnet start
midnight-status-codes:lookup 0x4b
midnight-fact-check:check path/to/article.md
midnight-expert:doctor
```

## License

MIT — Copyright (c) 2026 Aaron Bassett
