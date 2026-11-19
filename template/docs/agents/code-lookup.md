---
title: Looking up code
summary: How agents find definitions, references, signatures, file outlines and type errors — through the language server the project enables as a Claude Code plugin, with a default per language.
layer: agents
status: implemented
components: [agents]
tags: [agents, navigation, context, lsp]
related:
  - agents/reading-strategy.md
  - agents/claude-code-setup.md
---

# Looking up code

Agents look up code through a language server, not by grepping or reading whole files.
Claude Code talks to the server through a plugin and gives the agent an `LSP` tool (go to definition, find references, hover, document symbols, go to implementation), plus the type errors in each file it edits.

## Which server

The project enables its language-server plugin in `.claude/settings.json`, so everyone working in the repo gets the same one.
The project's `docs/architecture/agent-tooling.md`, when it has one, names the server and why it was chosen; that choice wins over the defaults below.
How to add a plugin marketplace and enable a plugin: [Claude Code's plugin docs](https://code.claude.com/docs/en/discover-plugins).

Without a project choice, the default is the official `<language>-lsp` plugin from Anthropic's `claude-plugins-official` marketplace, for example `pyright-lsp`, `typescript-lsp`, `gopls-lsp` or `rust-analyzer-lsp`.
Python is the exception: its default is `pyrefly-lsp` from [imposeren/pyrefly-lsp](https://github.com/imposeren/pyrefly-lsp) (a Claude Code plugin marketplace), so the type errors seen while editing match the Pyrefly type checker.

The plugin only tells Claude Code how to start the server; the server itself must be installed where the plugin's README says.

## Which tool

| Question | Use |
| -- | -- |
| Where is X defined? Who uses X? | `LSP` tool: go to definition, find references. |
| Signature, types and docstring of one symbol | `LSP` tool: hover. |
| Outline of one file | `LSP` tool: document symbols. |
| Type errors after an edit | Reported automatically after each edit; no command needed. |

## Rules

- **Use the `LSP` tool before grep** for anything a symbol answers.
- **No result is not proof of absence.**
  Some servers return nothing for workspace symbol search or for code in gitignored paths, such as installed libraries; fall back to document symbols, hover or grep instead of retrying.
- **The code is not the spec.**
  If a doc and the code disagree, the doc is the target and the code may lag behind ([reading-strategy.md](reading-strategy.md#dont)).
- **Without a language server** (plugin not enabled, or the server not installed): grep the code.

## See also

- [reading-strategy.md](reading-strategy.md) — finding and reading docs.
- [claude-code-setup.md](claude-code-setup.md) — the project's Claude Code files.
