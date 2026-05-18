# Argus — Claude Code Instructions

Big Health's org-wide engineering documentation. Canonical for engineering process, standards, TDDs and ADRs (org-wide and per-area), and cross-team architecture overviews.

## Process for changes to this repo

- All changes via Draft PR → Ready → required approvals → merge. See `process/engineering-handbook.md` "Documentation PR workflow".
- TDDs and ADRs are filed under `areas/<area>/{tdds,adrs}/`. The taxonomy of areas lives in `areas/README.md`.
- Cross-cutting decisions (not tied to a single product/area) go under `areas/general/`.
- Standards in `standards/` apply to all projects unless an ADR explicitly deviates.

## Where things go (within argus)

- TDDs → `areas/<area>/tdds/TDD-[slug].md`
- ADRs → `areas/<area>/adrs/ADR-[slug].md`
- Templates → `templates/tdd-template.md`, `templates/adr-template.md`
- Standards → `standards/` (coding, testing, API design)
- Process docs → `process/`
- Architecture overviews → `architecture/` (require named owner + last-reviewed date)

## Authoring TDDs and ADRs

- Use the MADR-aligned templates: `templates/tdd-template.md` and `templates/adr-template.md`. Both have a YAML frontmatter contract on top.
- Filenames are slug-based: `TDD-[slug].md`, `ADR-[slug].md`. No numeric prefix. The slug in the filename is the canonical ID and also appears as the `tdd:` or `adr:` field in frontmatter.
- Pick the most specific applicable area. If a decision genuinely spans areas, file under `general/` and use `related_areas:` in frontmatter to flag the others.

The full engineering handbook (which you're maintaining) is `process/engineering-handbook.md`.
