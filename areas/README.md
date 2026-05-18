# Areas

Engineering design docs in argus are filed under flat product/architectural-area folders. Each area folder contains its own `tdds/` and `adrs/` subdirectories.

## Seed taxonomy

- `entropy/`
- `aware/`
- `engage/`
- `canopy/`
- `sleepio/`
- `daylight/`
- `spark/`
- `cortex/`
- `billflow/`
- `user-funnel/`
- `nhse/`
- `xealth/`
- `redox/`
- `web-order-form/`
- `direct-orders-api/`
- `provider-portal/`
- `general/` — cross-cutting decisions not tied to a single area

## Adding, renaming, or merging an area

Open a PR that:

1. Edits this list.
2. `git mv`s the folder (or creates a new one with `.gitkeep`s in `tdds/` and `adrs/`).
3. Updates any docs that referenced the old name.

One approver is enough. Names are kebab-case. If an area is unclear in scope, default it to `general/` until usage patterns clarify it.

## File conventions

- TDDs: `areas/<area>/tdds/TDD-[slug].md`
- ADRs: `areas/<area>/adrs/ADR-[slug].md`
- No numeric prefixes. The slug in the filename is the canonical ID.
- Frontmatter contract: see `../templates/tdd-template.md` and `../templates/adr-template.md`.

For the overall process — when to author each doc type and how to land changes — see [`../process/engineering-handbook.md`](../process/engineering-handbook.md).
