# docs-driven-template

A [Copier](https://copier.readthedocs.io) template for **documentation-driven** projects: the docs in a project's `docs/` are the finished spec of the system, and code follows them.

What a project gets, from [`template/`](template/):

- the rules for writing, linking and versioning docs, the glossary and the doc templates ([template/docs/meta/](template/docs/meta/index.md));
- empty skeletons of the documentation layers ([what layers are](template/docs/meta/layers.md): behavior, scenarios, architecture, ui, guides, reference) and a roadmap with a placeholder milestone;
- guidance for AI agents ([template/docs/agents/](template/docs/agents/index.md)), Claude Code agents and the `/new-doc` skill (`.claude/`), and a `CLAUDE.md`;
- the generic architecture decisions `BASE-0001`…`BASE-0006` ([template/docs/architecture/decisions/](template/docs/architecture/decisions/index.md));
- the commit hooks (`.pre-commit-config.yaml`, run by [prek](https://github.com/j178/prek)) and the docker compose services that check, build and serve the docs.

Docs are checked and rendered by [docspecsite](https://github.com/imposeren/docspecsite), at the version pinned in the project's `.pre-commit-config.yaml` and `compose.yaml`.
The template is language-agnostic: a project adds its own toolchain.
Why Copier: [BASE-0006](template/docs/architecture/decisions/BASE-0006-projects-created-with-copier.md).

## Create a project

You need [uv](https://docs.astral.sh/uv/) (to run Copier) and git.

```
uvx copier==9.19.1 copy https://github.com/imposeren/docs-driven-template.git <project-dir>
```

Copier asks for the project's name, a one- or two-sentence description, its repository URL (optional), its own ADR prefix (see below) and the docspecsite release to pin (by default the one this template release was checked with), and writes `.copier-answers.yml` with the answers and the template version.
It uses the template's latest release tag; `--vcs-ref <tag>` picks another one.

The same command also applies the template to an existing repository: run it in that repository on a clean working tree, then review the changes before committing them.

**ADR prefix:** an ADR (architecture decision record) is a short doc that records one technical decision: its context, the options considered and the choice.
ADRs are named `<PREFIX>-NNNN`, such as `APP-0003`; the prefix tells whose decision it is, so IDs stay unique when ADRs from several sources sit in one repo.
The template's own ADRs are `BASE-*`; the project picks its own prefix, capital letters only, such as `APP` ([ADR IDs](template/docs/meta/structure.md#adr-ids)).

Then:

1. Fill in the remaining placeholders in angle brackets in `CLAUDE.md` (hosting, status line).
2. Describe the project in the docs: `docs/behavior/index.md`, the components in `docs/architecture/components.md`, the milestones in `docs/roadmap.md`.
3. Set up your machine: `docs/guides/contributor-setup.md`.

## Update a project

Taking the template's later changes is optional. Either:

- run `uvx copier==9.19.1 update` in the project on a clean working tree: it applies the changes since the recorded version as a 3-way merge, with conflict markers where the project changed the same lines; or
- let an agent compare the template versions and carry over what fits.

Files the project owns once it exists are never overwritten: its `CLAUDE.md`, `README.md`, `.gitignore`, `docspecsite.toml`, compose and prek config, the layer index pages, the roadmap, components, glossaries, decisions index and contributor guide.
They also never receive template changes: when an update adds a template doc, such as a new `BASE` ADR, add its line to the index page yourself; `docspecsite check` names the missing entry.
Review the result and commit it like any change.

## Develop the template

The template has no docs or commit hooks of its own at its root.
Check a change by creating sample projects and running their checks:

```
scripts/check-sample-project.sh
```

It needs uv, git and prek. `DOCSPECSITE_VERSION=<tag>` checks against another docspecsite release than the template's default.

## License

MIT No Attribution (MIT-0), see [LICENSE](LICENSE). Projects created from the template don't get this license; each chooses its own.
