#!/usr/bin/env bash
# Check the template: create sample projects from it with Copier and run each project's own commit hooks there
# (prek, including docspecsite's docs check). Uses the working tree (--vcs-ref HEAD, uncommitted changes included);
# without it Copier would copy the latest release tag.
# Needs uv, git and prek. On a failure the sample projects are kept and their directory is printed.
# DOCSPECSITE_VERSION=<tag> checks against another docspecsite release than the template's default.
set -euo pipefail

# Keep equal to _min_copier_version in copier.yml and to the version in README.md.
COPIER_VERSION=9.19.1
template_dir="$(cd "$(dirname "$0")/.." && pwd)"
work_dir="$(mktemp -d)"

# Report a failed check, keep the sample projects for inspection, and stop.
fail() {
    echo "FAIL: $1" >&2
    echo "Sample projects kept in $work_dir" >&2
    exit 1
}

# Create the sample project <name> with the given extra Copier arguments (--data answers).
copy_sample() {
    local name="$1"
    shift
    uvx --quiet "copier==$COPIER_VERSION" copy --quiet --defaults --overwrite --vcs-ref HEAD \
        --data project_name="Sample $name" \
        --data project_description="A sample project for checking the template." \
        --data repo_url="https://github.com/example/sample-$name" \
        --data adr_prefix=SMP \
        ${DOCSPECSITE_VERSION:+--data "docspecsite_version=$DOCSPECSITE_VERSION"} \
        "$@" "$template_dir" "$work_dir/$name"
}

# Commit the sample project <name> and run its commit hooks on all files.
check_sample() {
    local name="$1"
    (
        cd "$work_dir/$name" &&
            git init --quiet &&
            git add --all &&
            git -c commit.gpgsign=false -c core.hooksPath=/dev/null -c user.name=check \
                -c user.email=check@example.invalid commit --quiet -m sample &&
            prek run --all-files
    ) || fail "sample project '$name' does not pass its own checks"
    echo "ok: $name"
}

# Assert that the sample project <name> has (yes) or lacks (no) a file, or a fixed line in a file.
expect_file() {
    local name="$1" expected="$2" path="$3"
    if [ -e "$work_dir/$name/$path" ]; then local found=yes; else local found=no; fi
    [ "$found" = "$expected" ] || fail "sample '$name': expected $path to exist: $expected"
}
expect_line() {
    local name="$1" path="$2" line="$3"
    grep --quiet --fixed-strings -- "$line" "$work_dir/$name/$path" || fail "sample '$name': $path lacks: $line"
}
expect_no_line() {
    local name="$1" path="$2" line="$3"
    ! grep --quiet --fixed-strings -- "$line" "$work_dir/$name/$path" || fail "sample '$name': $path has: $line"
}
# Assert that the sample project <name> has none of the Pyrefly option's parts.
expect_no_pyrefly() {
    local name="$1"
    expect_file "$name" no docs/architecture/decisions/PYRF-0001-pyrefly-language-server.md
    expect_no_line "$name" docspecsite.toml "PYRF"
    expect_no_line "$name" docs/architecture/decisions/index.md "PYRF"
}

# No languages: no plugins, no option ADRs.
copy_sample no-languages || fail "creating the sample project 'no-languages'"
check_sample no-languages
expect_file no-languages no .claude/settings.json
expect_no_pyrefly no-languages

# Python with Anthropic's Pyright plugin, plus HTML and CSS (no plugin).
copy_sample python-official --data 'languages=["python", "html-css"]' || fail "creating 'python-official'"
check_sample python-official
expect_line python-official .claude/settings.json '"pyright-lsp@claude-plugins-official": true'
expect_line python-official docs/agents/code-lookup.md "| HTML and CSS | none: agents use grep |"
expect_no_pyrefly python-official

# Python with Pyrefly, TypeScript, and other languages named only in the docs.
copy_sample python-pyrefly-ts --data 'languages=["python", "typescript-javascript"]' \
    --data python_language_server=pyrefly --data other_languages="SQL, Bash" || fail "creating 'python-pyrefly-ts'"
check_sample python-pyrefly-ts
expect_line python-pyrefly-ts .claude/settings.json '"pyrefly-lsp@claude-pyrefly-lsp": true'
expect_line python-pyrefly-ts .claude/settings.json '"repo": "imposeren/claude-pyrefly-lsp"'
expect_line python-pyrefly-ts .claude/settings.json '"typescript-lsp@claude-plugins-official": true'
expect_file python-pyrefly-ts yes docs/architecture/decisions/PYRF-0001-pyrefly-language-server.md
expect_line python-pyrefly-ts docspecsite.toml 'external-adr-prefixes = ["BASE", "PYRF"]'
expect_line python-pyrefly-ts docs/agents/code-lookup.md "| SQL | none: agents use grep |"
echo "ok: language options"

# A project's own content survives copying the template again.
echo "Project-owned line." >> "$work_dir/no-languages/docs/index.md"
copy_sample no-languages || fail "copying the template again over 'no-languages'"
grep --quiet --fixed-strings --line-regexp "Project-owned line." "$work_dir/no-languages/docs/index.md" \
    || fail "copying again overwrote the project's docs/index.md"
echo "ok: project-owned files are kept"

# The prefixes of the template's ADRs are refused as a project's ADR prefix, by the question's validator.
for template_prefix in BASE PYRF; do
    if bad_prefix_output="$(copy_sample bad-prefix --data adr_prefix="$template_prefix" 2>&1)"; then
        fail "adr_prefix=$template_prefix was accepted"
    fi
    grep --quiet --fixed-strings "$template_prefix is a prefix of the template's ADRs" <<< "$bad_prefix_output" \
        || fail "adr_prefix=$template_prefix failed for another reason: $bad_prefix_output"
    echo "ok: adr_prefix=$template_prefix is refused"
done

# Other languages must not repeat a selectable language or break the docs' table.
for bad_other_languages in "Python, SQL:in the languages question instead" "C|C++:Leave out"; do
    other_languages="${bad_other_languages%%:*}"
    expected_message="${bad_other_languages#*:}"
    if bad_other_output="$(copy_sample bad-other-languages --data other_languages="$other_languages" 2>&1)"; then
        fail "other_languages=\"$other_languages\" was accepted"
    fi
    grep --quiet --fixed-strings "$expected_message" <<< "$bad_other_output" \
        || fail "other_languages=\"$other_languages\" failed for another reason: $bad_other_output"
done
echo "ok: bad other_languages are refused"

rm -rf "$work_dir"
