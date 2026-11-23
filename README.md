# docs-driven-template

A [Copier](https://copier.readthedocs.io) template for **documentation-driven** projects: the docs in a project's `docs/` are the finished spec of the system, and code follows them.

What a project gets, from [`template/`](template/):

- the rules for writing, linking and versioning docs, the glossary and the doc templates ([template/docs/meta/](template/docs/meta/index.md));
- empty skeletons of the documentation layers ([what layers are](template/docs/meta/layers.md): behavior, scenarios, architecture, ui, guides, reference) and a roadmap with a placeholder milestone;
- guidance for AI agents ([template/docs/agents/](template/docs/agents/index.md)), Claude Code agents and the `/new-doc` skill (`.claude/`), and a `CLAUDE.md`;
- language servers agents use to look up code, for the project's Python and TypeScript/JavaScript code, enabled in `.claude/settings.json`;
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

Copier asks for the project's name, a one- or two-sentence description, its repository URL (optional), its own ADR prefix (see below), the languages its code is in (Python, TypeScript and JavaScript, HTML and CSS, or others named in the docs; for Python also which language server agents use: Anthropic's `pyright-lsp`, or `pyrefly-lsp` for projects that type-check with Pyrefly) and the docspecsite release to pin (by default the one this template release was checked with), and writes `.copier-answers.yml` with the answers and the template version.
It uses the template's latest release tag; `--vcs-ref <tag>` picks another one.

The same command also applies the template to an existing repository: run it in that repository on a clean working tree, then review the changes before committing them.
It writes every file that is not project-owned (see below), so restore from git what the project had changed in those, such as its own `.claude/settings.json` entries.

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

Files the project owns once it exists are never overwritten: its `CLAUDE.md`, `README.md`, compose and prek config, the layer index pages, the roadmap, components, glossaries, decisions index and contributor guide, and the architecture docs it extends with its own tools (dev environment, quality gate, versioning).
They also never receive template changes: when an update adds a template doc, such as a new `BASE` ADR or the `PYRF-0001` of a newly chosen option, add its line to the index page yourself; `docspecsite check` names the missing entry.
Other files, such as `.gitignore`, `docspecsite.toml` and `.claude/settings.json`, are merged, so the project's own changes stay.
An ADR is never deleted: when the project drops an option, such as Pyrefly, supersede the option's ADR instead of letting the update remove it.
Two changes need a manual fix after every update:

- the template docs (`docs/meta/`, `docs/agents/`) arrive with the template's `status`, which follows what the pinned docspecsite release builds; where the project's own status differs (docspecsite itself builds ahead of its last release), set it back;
- template files the project deleted, such as an unused `docs/reference/` section, come back; delete them again.
Review the result and commit it like any change.

## Develop the template

The template has no docs or commit hooks of its own at its root.
Check a change by creating sample projects and running their checks:

```
scripts/check-sample-project.sh
```

It needs uv, git and prek. `DOCSPECSITE_VERSION=<tag>` checks against another docspecsite release than the template's default.

A template doc is `implemented` only when the default docspecsite release builds what it describes, so a spec that docspecsite has not released yet stays `specified` here.
When you raise the default `docspecsite_version`, set every template doc that the new release builds to `implemented` in the same change.

## License

MIT No Attribution (MIT-0), see [LICENSE](LICENSE). Projects created from the template don't get this license; each chooses its own.
