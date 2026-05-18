# argus

Engineering documentation for Big Health. The canonical home for TDDs, ADRs, standards, process docs, and architecture overviews across the organization.

## What lives here

- **`areas/`** — TDDs and ADRs, filed by product/architectural area. Each area folder contains its own `tdds/` and `adrs/`. See [`areas/README.md`](areas/README.md) for the taxonomy and the rule for adding or renaming an area.
- **`templates/`** — MADR-aligned templates for TDDs and ADRs, with the YAML frontmatter contract.
- **`standards/`** — Coding standards, testing philosophy, API design conventions.
- **`process/`** — Engineering process docs. Start with [`process/engineering-handbook.md`](process/engineering-handbook.md).
- **`architecture/`** — Cross-team architectural overviews. Each entry has a named owner and last-reviewed date.

## What does NOT live here

Project-local phasing plans live in the originating project repo at `doc/phasing/`. Working ticket context lives at `[project]/.claude/tickets/` (gitignored). See the engineering handbook, *Section 3: Document structure*.

## How to contribute

See [`CONTRIBUTING.md`](CONTRIBUTING.md). Short version: open a Draft PR, ping reviewers manually, promote to Ready when feedback is incorporated, merge is the formal approval gate.

## Referencing argus docs

Refer to TDDs and ADRs by their slug: "ADR-idempotency-keys" or "TDD-claims-validator." From code in a project repo, link to argus docs by full GitHub URL.
