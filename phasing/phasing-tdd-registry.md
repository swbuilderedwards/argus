# TDDs in primary repo, registry in argus — rollout

## Decision

TDDs live in their primary repo at `[repo]/doc/tdds/`. Argus hosts an auto-generated registry. No team folders anywhere — ownership lives in TDD frontmatter. Co-location preserves the write path (TDD and code evolve in the same PR); the registry provides a single read path for cross-team discovery.

## Frontmatter contract

Every TDD includes:

```yaml
---
tdd: TDD-claims-validator         # canonical ID (slug-based)
title: CVS Claims Validator
epic: BL-1234                     # primary Jira epic; null while in draft
related_epics: [BL-5678]          # optional, for cross-cutting work
owners: [wellness-team]
status: draft | accepted | superseded
superseded_by: TDD-replacement    # only if status=superseded
---
```

`epic:` must be set before `status` moves from `draft` to `accepted`.

## Filename convention

`TDD-[slug].md`. No numeric prefix. Slug is the human handle; the `tdd:` frontmatter field is the canonical ID.

## Work, in order

### 1. Build the registry generator (argus)

- `argus/.github/workflows/regenerate-tdd-registry.yml` — scheduled (nightly) GitHub Action.
- Reads `argus/config/tdd-repos.yaml` (list of enrolled repos).
- For each enrolled repo, fetches `doc/tdds/*.md`, parses frontmatter.
- Regenerates `argus/doc/tdd-registry.md` as a markdown table (epic key, title, repo path, owners, status).
- Opens a PR to argus if the registry changed.
- Must work correctly with zero enrolled repos (registry exists, body is "no TDDs registered").

### 2. Pilot: backfill `vercel-billflow` TDDs

- Add frontmatter to each existing TDD under `vercel-billflow/doc/tdds/`.
- Rename files to `TDD-[slug].md` form (drop the numeric prefix).
- Enroll `vercel-billflow` in `argus/config/tdd-repos.yaml`.
- Verify next scheduled run picks them up.

### 3. Update `/bh-ticket-start` to resolve TDDs via the registry

- Fetch `argus/doc/tdd-registry.md` on demand; cache for the session.
- Resolution path: ticket → parent epic key → registry row → repo path → load TDD.
- Fall back to existing behavior if the registry is unreachable.

### 4. Land the handbook PR

Section-by-section diff (handbook lives at `argus/process/engineering-handbook.md`):

- **Section 3 (Document structure)** — replace the TDD location line:
  - TDDs → `[repo]/doc/tdds/TDD-[slug].md` (frontmatter required)
  - TDD registry → `argus/doc/tdd-registry.md` (auto-generated; do not edit by hand)
- **Phase 1 (Feature planning)** — add bullet: "TDD frontmatter must include `epic:` before status moves from `draft` to `accepted`."
- **Phase 3 (Per-ticket implementation)** — replace the `/bh-ticket-start` description with the registry-driven lookup.
- **New section "TDD registry"** (sibling to "Documentation PR workflow") — three short blocks: where it lives, frontmatter contract, how to enroll a repo.
- **Section 4 (Rationale)** — append "Why TDDs stay in their primary repo" (~150 words). Co-location for the write path, registry for the read path, team folders rot through reorgs, cross-team TDDs need a clear home.

### 5. Rollout to other repos (post-handbook)

- Each team backfills their own TDDs as a PR.
- Each team enrolls their repo in `argus/config/tdd-repos.yaml`.
- No central bottleneck; proceeds on team-by-team timeline.

## Out of scope (for now)

- **ADRs in the registry.** Project ADRs stay in `[repo]/doc/adrs/`. Lower volume, less cross-team read pressure. Revisit once the TDD registry is proven.
- **Push-based registry updates.** Scheduled pull is sufficient for cross-team reads. Add push-on-merge later if staleness becomes a problem.
- **Globally unique TDD numbers.** Slug is the identifier; numeric IDs create a coordination bottleneck for no real benefit.
- **Team folders.** Ownership lives in `owners:` frontmatter, which survives reorgs.

## Open questions

_(none currently; record here if any arise)_

## Status

- 2026-05-17 — phasing plan written. Argus has no other users yet; policy is provisional until step 4 (handbook PR) lands. David is sole builder of argus at this time.
