# Contributing to argus

argus is the canonical home for engineering decisions, standards, process docs, and TDDs across Big Health. The repo is the source of truth; Confluence is a downstream read-only mirror (once the sync is built).

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

## TDDs and ADRs

- File under `areas/<area>/{tdds,adrs}/`. See [`areas/README.md`](areas/README.md) for the taxonomy and the rule for adding or renaming an area.
- Use the [TDD template](templates/tdd-template.md) or [ADR template](templates/adr-template.md). Both are MADR-aligned with a YAML frontmatter contract on top.
- Filenames are slug-based: `TDD-[slug].md`, `ADR-[slug].md`. No numeric prefix.
- Cross-cutting decisions not tied to a single product/area go under `areas/general/`. Use `related_areas:` in frontmatter to flag connections to specific areas.

## Standards

Argus standards are assumed to apply to all projects unless an ADR explicitly deviates. Deviations must link to the argus standard they deviate from.

## Architecture overviews

Every entry in `architecture/` requires a named owner and a last-reviewed date. Unowned overviews are removed.
