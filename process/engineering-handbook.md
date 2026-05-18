# Engineering Handbook

**Status:** Target-state specification. Gaps between current state and target are called out in *Section 5: Known gaps*.

**Scope:** Engineering process and documentation structure, from PRD-in-hand through to PR-ready. Engineer-reviewed artifacts only. Out of scope: PM/design phases, non-engineer-reviewed docs, QA acceptance testing.

---

## Section 1: Quick reference

### Where does a document live?

| Artifact | Location |
|---|---|
| TDD | `argus/areas/<area>/tdds/TDD-[slug].md` |
| ADR | `argus/areas/<area>/adrs/ADR-[slug].md` |
| TDD / ADR template | `argus/templates/tdd-template.md`, `argus/templates/adr-template.md` |
| Standard or style guide | `argus/standards/` |
| Engineering process docs (this doc) | `argus/process/` |
| Architectural overview | `argus/architecture/` |
| Phasing plan | `[project]/doc/phasing/phasing-[feature].md` |
| Per-ticket working context | `[project]/.claude/tickets/[ticket-id]/` (local only, gitignored) |

**Where to file:** Pick the most specific applicable area in `argus/areas/`. Cross-cutting decisions that aren't tied to a single product or area go under `areas/general/`. When unsure, default to `general/` until usage patterns clarify scope. See [`../areas/README.md`](../areas/README.md) for the seed taxonomy and the rule for adding or renaming an area.

---

### What skill to run, and when?

| When | Skill |
|---|---|
| Before engineering specifies anything | `/plan-ceo-review` |
| Producing the TDD | `/plan-eng-review` |
| Feature has UI | `/plan-design-review` |
| Per-ticket planning | Plan mode (seeded with TDD) |
| Something breaks during implementation | `/investigate` |
| Implementation complete — code review | `/review` |
| Implementation complete — UI polish | `/design-review` |
| Implementation complete — security-sensitive ticket | `/cso` |
| Implementation complete — final health check | `/codex` |
| Closing a ticket | `/bh-ship` *(not yet built — see gaps)* |

---

### Process at a glance

```
PRD + design spec
        │
        ▼
┌──────────────────────────────────────┐
│ Phase 1: Feature planning             │
│   /plan-ceo-review                    │
│   /plan-eng-review  → TDD             │
│   /plan-design-review (UI only)       │
│   Manual ADR(s) if warranted          │
│   PR review → merge → Confluence sync │
└──────────────────────────────────────┘
        │ TDD + ADRs locked
        ▼
┌──────────────────────────────────────┐
│ Phase 2: Phasing + ticketing          │
│   Phasing plan (Claude Code, prompted)│
│   /jira-ticket-authoring              │
└──────────────────────────────────────┘
        │ Tickets created
        ▼
┌──────────────────────────────────────┐
│ Phase 3: Per-ticket implementation    │
│   Load TDD + ticket                   │
│   /careful + /freeze                  │
│   Plan mode (seeded with TDD)         │
│   Agentic implementation              │
│   /investigate on breakage            │
│   Working context → .claude/tickets/  │
└──────────────────────────────────────┘
        │ Implementation complete
        ▼
┌──────────────────────────────────────┐
│ Phase 4: Pre-PR gates                 │
│   /review (always)                    │
│   /design-review (UI)                 │
│   /cso (security-sensitive)           │
│   /codex (always)                     │
└──────────────────────────────────────┘
        │ All gates pass
        ▼
   PR ready for QA
        │ At ticket close
        ▼
┌──────────────────────────────────────┐
│ /bh-ship                              │
│   → /ship → /retro                    │
│   → Promotion checkpoint              │
└──────────────────────────────────────┘
```

---

## Section 2: The process

### Phase 1 — Feature planning

**Inputs:** PRD, design spec (if applicable)
**Outputs:** TDD, ADR(s)
**Where:** Claude Code session with PRD and design spec loaded

**Skills, in order:**
1. `/plan-ceo-review` — Run first, always.
2. `/plan-eng-review` — Produces the TDD. Run against the full feature; comprehensiveness is appropriate here.
3. `/plan-design-review` — UI features only.

**TDD:** The output of `/plan-eng-review` becomes the TDD with light editing. File it under the most specific applicable area at `argus/areas/<area>/tdds/TDD-[slug].md`. TDD frontmatter must include `epic:` before its `status` moves from `draft` to `accepted`. Must be reviewed and merged via PR before Phase 2 begins.

**ADRs:** After `/plan-eng-review`, review the TDD for decisions that warrant a standalone ADR. Author one ADR per decision using the MADR template at `templates/adr-template.md`. A decision warrants an ADR when it constrains future work, rejects a plausible alternative for non-obvious reasons, or would prompt a future engineer to ask "why did we do it this way?" File each ADR under the most specific applicable area at `argus/areas/<area>/adrs/ADR-[slug].md`. Cross-cutting decisions go under `areas/general/`.

**Review and publish:** Both TDD and ADRs go through the documentation PR workflow (see *Documentation PR workflow* below) before Phase 2 starts.

---

### Phase 2 — Phasing plan and Jira tickets

**Inputs:** Locked, merged TDD
**Outputs:** Phasing plan, Jira tickets

Do not start Phase 2 until the TDD is merged. Tickets created against an unstable TDD will be rewritten.

Produce the phasing plan by loading the TDD into Claude Code and prompting for a sequencing breakdown — identifying dependencies, sequence constraints, and milestones. Save as `[project]/doc/phasing/phasing-[feature].md`. The phasing plan is project-local and is not synced to Confluence.

Run `/jira-ticket-authoring` to convert the locked TDD and phasing plan into Jira tickets.

---

### Phase 3 — Per-ticket implementation

**Inputs:** TDD, Jira ticket
**Outputs:** Code, ephemeral working context, promoted insights (if any)

**Session setup — do these before anything else:**
1. Load the TDD into context. TDDs live in argus under `areas/<area>/tdds/`. When available, `/bh-ticket-start` resolves a ticket to its TDD by greping frontmatter `epic:` across `argus/areas/`; otherwise navigate by area.
2. Load the Jira ticket.
3. Run `/careful` and `/freeze` (or `/guard`).

**Planning:** Use plan mode seeded with the relevant TDD section. Do not use `/plan-eng-review` at the ticket level — it will over-scope. Write the output to `.claude/tickets/[ticket-id]/plan.md`.

**Implementation:** Agentic execution against the plan.

- On breakage: `/investigate` before any fix. No exceptions.
- On a new edge case: a new edge case is something the TDD didn't anticipate but doesn't invalidate its overall approach — for example, a data shape that differs from what was assumed, an integration constraint that wasn't known at planning time, or a failure mode the TDD's test plan didn't cover. Pause, run `/plan-eng-review` on the specific discovery (not the whole ticket), update the TDD via PR in argus, then continue. If you find yourself questioning the architectural approach rather than filling in a gap, that's not a new edge case — see the bullet below.
- On a broken architectural approach: stop the ticket. Re-open Phase 1. See *Rationale — what to do when the TDD is wrong*.

**Working context:** `.claude/tickets/[ticket-id]/` holds plan files, notes, failed approaches — anything needed for session continuity. This directory is gitignored always and never committed. Files persist on local disk for the ticket's lifetime. At ticket close, review for promotable insights, then delete.

**Promotion at ticket close:** Run `/bh-ship` *(not yet built)*. It reviews working context, surfaces insights worth keeping, and routes confirmed candidates through the documentation PR workflow as TDD amendments or new ADRs in argus.

---

### Phase 4 — Pre-PR gates

Run in sequence when implementation is complete.

| Gate | When to run |
|---|---|
| `/review` | Always |
| `/design-review` | Ticket touches UI |
| `/cso` | Ticket touches auth, data storage, PHI/PII, or external integrations |
| `/codex` | Always |

PR is ready for QA when all applicable gates pass.

---

### Documentation PR workflow

Applies to TDDs, ADRs, and amendments to either, in argus.

1. Open a **Draft PR**. State in the description what kind of feedback is wanted: directional, line edits, or ready-to-approve.
2. Ping reviewers manually in Slack or a PR comment. Draft PRs do not trigger review-request notifications.
3. Reviewers comment or use GitHub's suggest-a-change feature.
4. When feedback is incorporated, promote to **Ready for Review**.
5. Required reviewers approve. Merge is the formal approval gate.
6. Merge to `main` triggers the Confluence sync. The doc appears in Confluence as read-only.

**Conventions:**
- No drafts folder. Draft PR status is the signal.
- Superseded or amended docs go through the same PR review gate.
- Confluence sync fires on merge to `main` only, never on PR activity.
- Comments on Confluence pages are out of bounds. Direction: raise a PR.

**Mechanical vs. norm enforcement:**

| Step | Enforcement |
|---|---|
| Required reviewers before merge | Mechanical (branch protection) |
| Confluence sync on merge | Mechanical (once built) |
| No Confluence editing | Norm |
| Manual reviewer ping on Draft | Norm |
| Stale draft PR cleanup | Norm (no automated nudge yet) |

---

## Section 3: Document structure

### argus — canonical home for engineering docs

```
argus/
├── README.md
├── CONTRIBUTING.md
├── templates/
│   ├── tdd-template.md
│   └── adr-template.md
├── standards/
│   ├── README.md
│   ├── coding/
│   │   ├── python.md
│   │   └── typescript.md
│   ├── testing-philosophy.md
│   └── api-design.md
├── process/
│   ├── README.md
│   └── engineering-handbook.md
├── architecture/
│   ├── README.md          ← owner + last-reviewed date per entry
│   └── ...
└── areas/
    ├── README.md          ← taxonomy + add/rename norm
    ├── entropy/
    │   ├── tdds/
    │   └── adrs/
    ├── billflow/
    │   ├── tdds/
    │   └── adrs/
    ├── general/           ← cross-cutting, not tied to one area
    │   ├── tdds/
    │   └── adrs/
    └── ...                ← other areas
```

TDD and ADR filenames are slug-based: `TDD-[slug].md`, `ADR-[slug].md`. No numeric prefix. The slug in the filename is the canonical ID and also appears as the `tdd:` or `adr:` field in YAML frontmatter. Refer to docs by slug ("ADR-idempotency-keys", "TDD-claims-validator") — the slug is descriptive enough that no qualifier is needed.

Architecture overviews require a named owner and last-reviewed date — unowned overviews are removed.

### Project repos — local working artifacts only

```
[project]/
├── .claude/
│   └── tickets/
│       └── [ticket-id]/   ← gitignored, local only
│           ├── plan.md
│           └── notes.md
└── doc/                   ← optional
    └── phasing/
        ├── README.md
        └── phasing-[feature].md
```

TDDs and ADRs do not live in project repos. Phasing plans may live project-local because they are working artifacts tied to a specific implementation effort, not cross-team reference material. Per-ticket working context is always gitignored.

### Cross-references between repos

Code in a project repo references TDDs and ADRs in argus by full GitHub URL (not relative paths, since the repos are separate):

> This module implements the design described in [TDD-claims-validator](https://github.com/Big-Health/argus/blob/main/areas/billflow/tdds/TDD-claims-validator.md).

Within argus, use relative paths between docs.

Argus standards are assumed to apply to all projects unless an ADR explicitly deviates. Deviations must link to the argus standard they deviate from.

---

## Section 4: Rationale

### Why repo-canonical, not Confluence-native?

The engineering team uses Confluence as their primary documentation surface. Authoring there is the path of least friction for reading and reviewing. So why is the repo canonical?

Two reasons that outweigh the friction:

The first is AI-assisted authoring. Claude Code works in the filesystem. Confluence via MCP is possible but slow — every edit is a round-trip API call with parsing overhead. For the kind of iterative, agent-assisted authoring that the gstack workflow produces, that latency is genuinely painful and will cause people to abandon the pattern.

The second is the PR review workflow. PR review — threaded line comments, one-click suggest-a-change, formal approval as a merge gate with timestamp and author — is strictly better than Confluence's page-level comment model. Confluence's review UX is weaker on all three counts.

The Confluence sync gives you the best of both: engineers author in the repo, the rest of the team reads in Confluence, and the sync makes it invisible. The risk is that someone edits the Confluence page. The mitigation is cultural: "raise a PR" is the enforced norm.

### Why area-first folders, not repo-canonical

An earlier version of this design had TDDs and ADRs live in their primary project repo, with an auto-generated registry in argus aggregating them for cross-team discovery. We pivoted to area-first folders in argus for three reasons.

First, some products and integrations don't have a clear primary repo. Xealth integration is mostly n8n workflows that don't live in a repo at all. Redox integration and Web Order Form span multiple repos. Repo-canonical filing made the natural question "where does this TDD go?" answerable only with awkward conventions.

Second, engineers navigate by product or architectural area, not by doc type or by repo. "I work on BillFlow" is a more common mental frame than "I'm looking for a TDD." Putting TDDs and the ADRs they spawn as siblings inside `areas/<area>/` matches how the work is actually scoped and read.

Third, a registry adds a hop. Discovery becomes "consult the registry, find the row, follow the link to a repo." Filesystem structure gives the same result with no indirection: `ls argus/areas/billflow/tdds/`.

The arguments for keeping engineering docs in a repo (AI-assisted authoring speed, PR review discipline) still hold — argus is itself a repo. What we lose is "TDD reviewed in the same PR as the code it describes." In practice this matters less than it sounds: Phase 1 already requires the TDD to be merged before implementation starts, so the TDD and code rarely change together anyway. Mid-implementation TDD amendments become small argus PRs, which is the same shape we'd already use for any cross-cutting change.

### Why `/plan-eng-review` at the feature level, plan mode at the ticket level

`/plan-eng-review` is a completeness tool. It surfaces everything — edge cases, data flow, state machines, failure paths. That comprehensiveness is the right behavior at the feature level, when you want the TDD to be a complete reference artifact.

At the ticket level, comprehensiveness is the wrong behavior. You have a scoped slice of work with architectural decisions already made upstream. Plan mode, seeded with the TDD, stays focused on that slice. `/plan-eng-review` doesn't know it's operating on a scoped slice — it will try to re-examine decisions the TDD already settled.

The risk of plan mode at the ticket level is missing cross-cutting concerns. The mitigation is loading the TDD before running plan mode. The TDD carries those concerns; plan mode doesn't need to rediscover them.

### What to do when the TDD's architectural approach is wrong

This is the scenario that process docs usually elide. The distinction from "a new edge case" matters:

A new edge case is a gap in the TDD — something it didn't anticipate. Patching it mid-implementation is usually fine: one targeted `/plan-eng-review` on the discovery, a small TDD amendment PR, continue.

A broken architectural approach is different in kind. The approach the TDD specified doesn't work. The scope of the change is large enough that other in-flight tickets and the phasing plan are likely affected. Patching this mid-ticket produces a TDD that's been edited under pressure, without proper review, by an engineer who is already mid-implementation and cognitively committed to a path. That's how architectural debt accumulates invisibly.

The right response is to stop the ticket, re-open Phase 1, revise the TDD through the normal review workflow, and revisit the phasing plan and downstream tickets. This is expensive and uncomfortable. It is less expensive than discovering the architectural problem after three more tickets have been built on top of it.

### Why `.claude/tickets/` is gitignored always

A previous version of this design proposed committing working context on the ticket branch and gitignoring it on main. This doesn't work: `.gitignore` does not strip already-committed files at merge time. A file committed on a branch will appear in main's history when that branch is merged, regardless of gitignore.

The committed-and-squashed alternative depends on a manual cleanup step in the merge workflow that is easy to forget. Gitignoring always is the only mechanically reliable option.

The cost is cross-machine session continuity: working context doesn't travel between machines automatically. Engineers who need cross-machine continuity handle it manually. This tradeoff is deliberate.

---

## Section 5: Known gaps

These pieces of the target state do not yet exist. Until they do, the corresponding steps fall back to manual or ad hoc handling.

### Confluence sync — not yet built

Sync fires on merge to `main`. Two open questions before building: Cloud or Data Center Confluence (determines API surface)? What happens when someone edits a Confluence page — silent overwrite or drift detection?

Until built: ADRs and TDDs live in the repo only. Confluence reference is manual.

### `/bh-adr` skill — not yet built

No gstack skill produces MADR-formatted ADRs. Until built, ADR authoring is manual: after `/plan-eng-review`, prompt Claude Code with `templates/adr-template.md` and relevant decision context.

The skill should: take a TDD or decision summary as input; produce a MADR-formatted file in the canonical ADR path (`areas/<area>/adrs/`); include status, context, decision, consequences, and alternatives considered.

### `/bh-ship` wrapper skill — not yet built

The promotion checkpoint at ticket close depends on `/bh-ship`, a custom wrapper that composes gstack's `/ship` and `/retro` without duplicating them. Until built, engineers run `/ship` and `/retro` directly and promotion is entirely discipline-based.

`/bh-ship` should: delegate to `/ship` (unchanged); delegate to `/retro` (unchanged); add a promotion checkpoint that reviews `.claude/tickets/[ticket-id]/` and surfaces candidate insights for TDD amendments or new ADRs in argus.

### Backfill of existing project-repo TDDs and ADRs

Engineering docs that currently live under `[project]/doc/tdds/` or `[project]/doc/adrs/` need to be moved into the correct argus area, renamed to slug form, given frontmatter, and the old project-repo locations deleted. Per-project PRs; can parallelize. Start with `vercel-billflow` since it has the most existing content.

### Taxonomy maintenance — no formal bar yet

Adding or renaming an area is a PR that edits `argus/areas/README.md` and `git mv`s the folder. Single-approver. We have not yet decided whether to raise the bar (e.g. require sign-off from a broader review group when scope is ambiguous) or who should care about pruning unused areas. Worth revisiting once enough areas exist to make the decision concrete.

### Stale draft PR cleanup — no convention yet

Draft PRs with no activity will accumulate. No automated nudge or norm exists yet. Worth deciding: an inactivity threshold, an owner, and whether the nudge is automated (GitHub Action) or manual.

### Non-engineer reviewer docs — deferred

Docs requiring PM, clinical, design, or ops review remain on the current ad hoc process. Real and unsolved; deliberately deferred.
