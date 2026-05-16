# Argus — Claude Code Instructions

Big Health's org-wide engineering documentation. Canonical for engineering process, standards, org-wide ADRs, and cross-team architecture overviews.

## Process for changes to this repo

- All changes via Draft PR → Ready → required approvals → merge. See `process/engineering-handbook.md` "Documentation PR workflow".
- **ADR scope:** argus is for decisions that apply across teams. Project-specific decisions belong in the originating project repo's `doc/adrs/`. See "ADR promotion ceremony" in the handbook for promoting project ADRs to argus.
- Standards in `standards/` apply to all projects unless a project ADR explicitly deviates.

## Where things go (within argus)

- Org-wide ADRs → `adrs/ADR-NNNN-*.md` (MADR format, template at `adrs/template.md`)
- Standards → `standards/` (coding, testing, API design)
- Process docs → `process/`
- Architecture overviews → `architecture/` (require named owner + last-reviewed date)

## Authoring ADRs

- Use MADR format. See `adrs/ADR-0001-use-madr-format.md` and `adrs/template.md`.
- Filenames flat: `ADR-NNNN-kebab-case-title.md`. Topical organization in `adrs/README.md`, not subdirectories.

The full engineering handbook (which you're maintaining) is `process/engineering-handbook.md`.
