---
adr: ADR-project-repos-vendor-handbook-essentials
title: "Project repos vendor handbook essentials in CLAUDE.md and ship `/bh-process`"
owners: [engineering]
status: accepted
---

# Project repos vendor handbook essentials in CLAUDE.md and ship `/bh-process`

- **Status:** Accepted
- **Deciders:** Engineering
- **Date:** 2026-05-16
- **Tags:** process, tooling, claude-code

## Context and Problem Statement

Project repos need engineering process rules — where TDDs/ADRs/phasing live, ticket-time behavior, pre-PR gates — applied automatically by Claude Code during working sessions. The canonical handbook (`process/engineering-handbook.md`) is ~21KB, too large to inline in every project's `CLAUDE.md`. But some of its rules are load-bearing: they govern decisions an agent makes *before* it would think to invoke a skill (saving a plan in the wrong directory, running `/plan-eng-review` at ticket level, skipping `/investigate` before a fix). A skill-only delivery fails by omission — by the time the agent decides to load process context, the wrong action is already done.

How do we deliver the handbook so that load-bearing rules are always-on, deep reference content is on-demand, and project repos don't accumulate drifted handbook copies?

## Decision Drivers

- **Load-bearing rules must be always-on** — applied automatically by every agent session, not gated on invocation
- **Artifact must ship in the repo** — `~/.claude/` skills are per-user and don't reach the team
- **Canonical source must remain argus** — no drift between argus and project copies of the handbook
- **First-contributor experience** — clone a project repo, open Claude Code, the rules apply correctly without reading the handbook first
- **Token cost discipline** — adding 21KB to every session's context is unacceptable

## Considered Options

- A) Essentials inline in `CLAUDE.md` only (no skill); deep content not available in-session
- B) `/bh-process` skill only; nothing in `CLAUDE.md`; deep and shallow both gated on invocation
- C) Hybrid — small load-bearing essentials block in `CLAUDE.md` *and* `/bh-process` skill for depth

## Decision Outcome

Chosen option: **"C (Hybrid)"**, because it's the only option that keeps load-bearing rules always-on (solving the omission failure mode of skill-only) while keeping the deep content live-fetched from argus (solving the drift failure mode of essentials-only).

Each project repo carries:

1. A `## Engineering process` section in its `CLAUDE.md` (~220 tokens) — the locations table, ticket-time rules, and pre-PR gates. Pasteable, stable, identical across repos.
2. A `.claude/skills/bh-process/SKILL.md` skill that uses `WebFetch` to pull the canonical handbook from `https://raw.githubusercontent.com/swbuilderedwards/argus/main/process/engineering-handbook.md` on invocation. Supports a section arg (`phase1`, `phase3`, `gates`, `doc-pr`, `adr-promotion`, etc.) to surface only the relevant section.

### Positive Consequences

- Load-bearing rules applied automatically with no agent decision required.
- Deep content always fresh — zero drift on the bulk of the handbook.
- Bootstrap pattern is small, copy-pasteable, and identical across project repos.
- New contributors get correct ticket-time behavior without reading 21KB upfront.

### Negative Consequences

- Each project repo carries a small vendored block that must be hand-updated when the load-bearing rules themselves change (expected to be rare).
- Skill requires network access to fetch the handbook. Offline fallback is to read `CLAUDE.md` essentials and visit the URL.
- Adds a ~220-token always-on cost to every Claude Code session in a project repo.

## Pros and Cons of the Options

### A) Essentials inline in CLAUDE.md only

The whole handbook copied into every project's `CLAUDE.md`. Or a strict subset that covers everything the agent might need.

- Good, because everything is always in context — no agent decision required.
- Bad, because either you copy the whole handbook (21KB context tax per session, multiplied across every project repo) or you copy a subset and lose access to ADR promotion ceremony, documentation PR workflow, rationale, etc.
- Bad, because copying the whole handbook into N project repos guarantees drift from argus the moment the canonical version changes.

### B) `/bh-process` skill only

`CLAUDE.md` is unchanged. All process information is loaded only when the agent or user invokes `/bh-process`.

- Good, because zero permanent context cost beyond the skill description.
- Good, because zero drift — the skill always fetches live.
- Bad, because **fails by omission.** An agent saving a ticket plan, deciding whether to run `/plan-eng-review`, or fixing a bug doesn't always realize it should consult a process skill first. By the time they do, the wrong action is already taken. The Phase 3 rules are not reference material — they're decision gates.

### C) Hybrid (chosen)

- Good, because load-bearing rules are unconditional (solves B's failure mode).
- Good, because deep content stays canonical in argus (solves A's drift).
- Good, because the always-on tax is small (~220 tokens) and the essentials block changes rarely.
- Bad, because the project repo carries two artifacts to bootstrap (the CLAUDE.md block and the skill directory) rather than one.

## Links

- [`process/engineering-handbook.md`](../../../process/engineering-handbook.md) — the canonical handbook this ADR governs delivery of
- [Repo is canonical for engineering docs](ADR-repo-canonical-for-engineering-docs.md) — the prior decision that established argus as canonical
- Reference implementation: BillFlow `.claude/skills/bh-process/SKILL.md` and the "Engineering process" section of BillFlow's root `CLAUDE.md` (both shipping in `vercel-billflow` via `feature/process` stacked on `feature/folder-structure`)
