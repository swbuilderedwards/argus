# TDDs and ADRs in argus, organized by area — rollout

## Decision

TDDs and ADRs are canonical in argus, filed under flat product/category folders under `argus/areas/`. Each area folder contains its own `tdds/` and `adrs/`. Argus is the single read and write surface for engineering design docs. Discovery is folder structure plus the Confluence sync. No registry; no per-repo `doc/tdds/` or `doc/adrs/` trees. Project repos keep only `.claude/tickets/` (gitignored) and, optionally, `doc/phasing/` for project-local phasing plans.

This supersedes the prior "TDDs in primary repo, registry in argus" plan. Reasons for the pivot:

- Some products (Xealth, Redox, Web Order Form) have no clear primary repo. Xealth in particular is mostly n8n workflows.
- Engineers should not have to consult a registry to find a doc — folder structure plus product-aligned naming is enough.
- Area-first nesting (`areas/billflow/tdds/`) puts TDDs and the ADRs they spawn side by side, which matches how engineers actually navigate.

## Directory layout

```
argus/
├── README.md
├── CONTRIBUTING.md
├── templates/
│   ├── tdd-template.md
│   └── adr-template.md
├── standards/
├── process/
├── architecture/
└── areas/
    ├── README.md            ← taxonomy + "how to add/rename" norm
    ├── entropy/
    │   ├── tdds/
    │   └── adrs/
    ├── aware/
    │   ├── tdds/
    │   └── adrs/
    ├── engage/
    ├── canopy/
    ├── sleepio/
    ├── daylight/
    ├── spark/
    ├── cortex/
    ├── billflow/
    ├── user-funnel/
    ├── nhse/
    ├── xealth/
    ├── redox/
    ├── web-order-form/
    ├── direct-orders-api/
    ├── provider-portal/
    └── general/             ← cross-cutting decisions not tied to one area
```

## Taxonomy

Seed list lives in `argus/areas/README.md`:

```
entropy, aware, engage, canopy, sleepio, daylight, spark, cortex,
billflow, user-funnel, nhse, xealth, redox, web-order-form,
direct-orders-api, provider-portal, general
```

`general/` holds cross-cutting decisions not tied to one product or area (e.g. "use MADR format," "idempotency keys for write APIs").

Adding, renaming, or merging a category is a PR that edits `argus/areas/README.md` and `git mv`s the folder. One approver is enough.

## Frontmatter contract

TDDs:

```yaml
---
tdd: TDD-claims-validator        # canonical ID (slug-based)
title: CVS Claims Validator
epic: BL-1234                    # primary Jira epic; null while in draft
related_epics: [BL-5678]         # optional, for cross-cutting work
related_areas: [engage]          # optional, for cross-cutting work
owners: [wellness-team]
status: draft | accepted | superseded
superseded_by: TDD-replacement   # only if status=superseded
---
```

ADRs:

```yaml
---
adr: ADR-idempotency-keys
title: Idempotency keys for write APIs
owners: [platform]
status: proposed | accepted | superseded
supersedes: [ADR-old-thing]      # optional
superseded_by: ADR-newer-thing   # only if status=superseded
---
```

Area is folder-encoded; not duplicated in frontmatter. `epic:` is required before a TDD's `status` moves from `draft` to `accepted`.

## Filename convention

`TDD-[slug].md`, `ADR-[slug].md`. No numeric prefix. Slug is the human handle; the `tdd:` / `adr:` frontmatter field is the canonical ID.

## Work, in order

### 1. Unwind the registry generator

- Delete `argus/.github/workflows/regenerate-tdd-registry.yml`.
- Delete `argus/config/tdd-repos.yaml` and the `config/` directory if empty.
- Delete the generator script and its tests.
- This reverts what shipped on the current branch in commits `87560f6` and `c980c6e`.

### 2. Create the argus doc structure

- `argus/areas/README.md` — taxonomy + the "how to add/rename a category" norm.
- `argus/templates/tdd-template.md` and `argus/templates/adr-template.md` (MADR-aligned).
- Under `argus/areas/`, one folder per seed category, each containing empty `tdds/` and `adrs/` subdirectories with `.gitkeep`.
- Move existing top-level ADRs (`ADR-0001-use-madr-format.md`, `ADR-0002`, `ADR-0003`) into `argus/areas/general/adrs/`, rename to slug form, update frontmatter.

### 3. Land the handbook PR

Section-by-section diff against `argus/process/engineering-handbook.md`:

- **Section 1 quick-reference table** — Project TDD/ADR rows become `argus/areas/<area>/tdds/TDD-[slug].md` and `argus/areas/<area>/adrs/ADR-[slug].md`. Phasing row remains project-local. Drop the "Multi-repo TDDs" paragraph.
- **Phase 1** — Drop "Most Phase 1 ADRs are project-scoped." Add: "File under the most specific applicable area in `argus/areas/`. Cross-cutting decisions go under `areas/general/`." Add the TDD frontmatter requirement (`epic:` before `accepted`).
- **Phase 3** — `/bh-ticket-start` resolves a ticket → TDD by greping frontmatter `epic:` across `argus/areas/`. No registry indirection.
- **ADR promotion ceremony section** — delete entirely. There is no promotion path; ADRs are filed in argus from day one.
- **Section 3 structure** — Single argus tree (the directory layout above). Project repo section keeps only `.claude/tickets/` (gitignored) and optionally `doc/phasing/`.
- **Section 3 cross-references** — Flip direction: project code references argus docs by full GitHub URL.
- **Section 4 rationale** — New subsection: "Why area-first folders, not repo-canonical." Drop the "TDD reviewed alongside its code" framing in "Why argus is separate from project repos"; keep the AI-authoring and PR-review arguments.
- **Section 5 known gaps** — Drop "argus bootstrap" (done in step 2) and "project repo `/doc` bootstrap" (no longer needed). Add "Taxonomy maintenance — bar for adding/renaming an area" as a small open item.

### 4. Backfill existing project-repo TDDs and ADRs

Per project repo, opened as a separate PR (can parallelize once step 3 lands):

- Audit existing `doc/tdds/` and `doc/adrs/` contents.
- For each doc: move into the right argus area, rename to slug form, add frontmatter, set `status:` appropriately.
- Delete the old project-repo locations in the same PR.

Start with `vercel-billflow` since it has the most existing content.

### 5. Retire project-repo `doc/` structures

Folded into step 4 per repo. After all repos are migrated:

- Update each project's `CLAUDE.md` to point at argus for engineering docs (`doc/tdds/` and `doc/adrs/` no longer exist).
- Keep `doc/phasing/` only if a project chose to keep phasing plans locally.

## Out of scope

- **Phasing plans.** Project-local working artifacts. Revisit if cross-team discovery pressure emerges.
- **Standards and architecture overviews.** Stay at their current top-level argus locations. `argus/architecture/` is reserved for org-level overviews; per-area architectural context lives in that area's TDDs.
- **Push-based Confluence sync, automated frontmatter validation.** Out of scope for now; frontmatter validation can be added as CI later if useful.
- **Globally unique TDD numbers.** Slug is the identifier.

## Open questions

- _(none currently; record here if any arise)_

## Status

- 2026-05-17 — supersedes the prior TDD-registry phasing plan after a design rethink driven by products without clear primary repos (Xealth, Redox, Web Order Form) and the accessibility cost of registry-based discovery. The registry generator workflow shipped in `87560f6` will be reverted as step 1. David is still sole builder of argus at this time.
