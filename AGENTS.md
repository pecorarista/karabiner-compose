# AGENTS.md

## Coding Rules

Keep changes focused on the requested task.
Prefer the existing Swift Package structure and data files over introducing new tooling.

## Communication

Communicate with the user in Japanese.

## Code Style

Write code comments in English.
Only add comments that explain context, intent, or non-obvious behavior.

Keep default compose sequence data in `Sources/KarabinerCompose/Resources/default-compose-sequences.tsv`.
When the TSV changes, regenerate `right-command-compose.json` with:

```sh
swift run karabiner-compose > right-command-compose.json
```

## Testing Policy

Do not add or update tests reflexively for small fixes, renames, refactors, or data-only changes.
Before adding tests, first review the existing relevant tests and confirm that a new test covers meaningful behavior or a known regression.

If an existing test fails after a change, treat the failure as useful signal: report the failing test and behavior difference first, then decide whether to fix the implementation or intentionally update the test.

When Swift code or compose data changes, run:

```sh
swift test
```

## Commit Messages

Use Conventional Commits: `<type>(<scope>): <description>` or `<type>: <description>`.
Allowed types: `fix`, `feat`, `ci`, `docs`, `refactor`, `perf`, or `test`.
Common scopes: `compose`, `keys`, `tests`, `docs`, or `config`.
Write commit messages in English as a single concise line.

## Before Pushing

Review the final diff for:
- Duplicate logic, code, or definitions.
- Unused code, files, settings, or assets.
- Unexplained magic numbers or strings.
- Names that are inconsistent with nearby code.
- Simpler or more efficient implementations.
- Large generated changes that should be regenerated from source data.

Check that no credentials, secrets, tokens, keys, or local environment values are included in the diff.

Squash commits into a single commit before pushing a branch for review.
After review feedback, commit follow-up fixes separately and push the new commit instead of amending or force-pushing, unless the user explicitly asks to rewrite history.

## Pull Requests

Use the commit message as-is for the PR title.

Write PR comments in Japanese and include:
- A concise summary of the changes.
- Anything that was not verified, if applicable.
