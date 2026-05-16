# Contributing to argus

argus is the canonical home for org-wide engineering decisions, standards, and process. The repo is the source of truth; Confluence is a downstream read-only mirror (once the sync is built).

## Documentation PR workflow

1. **Open a Draft PR.** State in the description what kind of feedback is wanted: directional, line edits, or ready-to-approve.
2. **Ping reviewers manually** in Slack or a PR comment. Draft PRs do not trigger review-request notifications.
3. Reviewers comment or use GitHub's suggest-a-change feature.
4. When feedback is incorporated, promote to **Ready for Review**.
5. Required reviewers approve. **Merge is the formal approval gate.**
6. Merge to `main` triggers the Confluence sync (once built). The doc appears in Confluence as read-only.

## Conventions

- No drafts folder. Draft PR status is the signal.
- Superseded or amended docs go through the same PR review gate.
- Comments on Confluence pages are out of bounds. Direction: raise a PR.

## ADRs

- ADRs in argus are org-wide. If you're documenting a decision that only constrains one project, author it in that project's `doc/adrs/` instead.
- Use the [MADR template](adrs/template.md).
- ADR filenames are flat numeric: `ADR-NNNN-title.md`. Topical organization belongs in `adrs/README.md`, not subdirectories.

## Promoting a project ADR to argus

See the engineering handbook, *ADR promotion ceremony*. The short version: cross-team review is required, and the originating project's ADR is updated to "Superseded by argus ADR-NNNN."

## Standards

Argus standards are assumed to apply to all projects unless a project ADR explicitly deviates. Deviations must link to the argus standard they deviate from.

## Architecture overviews

Every entry in `architecture/` requires a named owner and a last-reviewed date. Unowned overviews are removed.
