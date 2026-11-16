# docs-driven-template

A starter for **documentation-driven** projects: the docs in [`docs/`](docs/index.md) are the finished spec of the system, and code follows them.

The template holds the method, not a product:

- the rules for writing, linking and versioning docs, the glossary and the doc templates: [docs/meta/](docs/meta/index.md);
- empty layer skeletons (behavior, scenarios, architecture, ui, guides, reference) and a roadmap with a placeholder milestone;
- guidance for AI agents ([docs/agents/](docs/agents/index.md)), Claude Code agents and the `/new-doc` skill (`.claude/`), and a `CLAUDE.md` with placeholders;
- the generic architecture decisions `BASE-0001`…`BASE-0005` ([docs/architecture/decisions/](docs/architecture/decisions/index.md));
- the commit hooks (`.pre-commit-config.yaml`, run by [prek](https://github.com/j178/prek)) and the docker compose services that check, build and serve the docs.

Docs are checked and rendered by [docspecsite](https://github.com/imposeren/docspecsite), at the version pinned in `.pre-commit-config.yaml` and `compose.yaml`.
The template is language-agnostic: a project adds its own toolchain.

## Start a project from the template

A project is a real git fork of the template, so it can pull later changes to the method.

1. Clone the template and name the remote `template`:
   ```
   git clone https://github.com/imposeren/docs-driven-template.git <project>
   cd <project>
   git remote rename origin template
   git remote add origin <your repo URL>
   git tag -l | xargs -r git tag -d
   git config remote.template.tagOpt --no-tags
   ```
   The template's release tags (`v0.1.0`, …) would clash with the project's own, so the clone drops them and later fetches skip them.
2. In `docspecsite.toml`, set `adr-prefix` to the project's own ADR prefix (short, uppercase, unique across the repos that share this template) and `source-url` to the project's repo.
   The `BASE-*` ADRs come from the template and keep their IDs; the project's own ADRs start at `<PREFIX>-0001` ([ADR IDs](docs/meta/structure.md#adr-ids)).
3. Fill in the placeholders (`<project name>` and others in angle brackets) in `CLAUDE.md`, and replace this README with the project's own.
4. Describe the project in the docs: `docs/index.md`, `docs/behavior/index.md`, the components in `docs/architecture/components.md`, the milestones in `docs/roadmap.md`.
5. Set up your machine: [docs/guides/contributor-setup.md](docs/guides/contributor-setup.md).

## Pull template updates

```
git fetch template && git merge template/main
```

Method changes are made once, in the template, and each project merges them.
When a change needs a newer docspecsite, bump its version in `.pre-commit-config.yaml` and `compose.yaml` together.

## Learn more

- How the docs work: [docs/meta/index.md](docs/meta/index.md)
- Working with Claude Code: [CLAUDE.md](CLAUDE.md) and [docs/agents/index.md](docs/agents/index.md)
- The docs tool: [docspecsite](https://github.com/imposeren/docspecsite)

## License

MIT No Attribution (MIT-0), see [LICENSE](LICENSE): a project started from this template may replace it with its own license.
