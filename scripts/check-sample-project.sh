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

copy_sample basic || fail "creating the sample project 'basic'"
check_sample basic

# A project's own content survives copying the template again.
echo "Project-owned line." >> "$work_dir/basic/docs/index.md"
copy_sample basic || fail "copying the template again over 'basic'"
grep --quiet --fixed-strings --line-regexp "Project-owned line." "$work_dir/basic/docs/index.md" \
    || fail "copying again overwrote the project's docs/index.md"
echo "ok: project-owned files are kept"

# The template's own prefix is refused as a project's ADR prefix, by the question's validator.
if bad_prefix_output="$(copy_sample bad-prefix --data adr_prefix=BASE 2>&1)"; then
    fail "adr_prefix=BASE was accepted"
fi
grep --quiet --fixed-strings "BASE is the template's prefix" <<< "$bad_prefix_output" \
    || fail "adr_prefix=BASE failed for another reason: $bad_prefix_output"
echo "ok: adr_prefix=BASE is refused"

rm -rf "$work_dir"
