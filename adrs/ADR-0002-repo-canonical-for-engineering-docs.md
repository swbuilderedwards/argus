# ADR-0002: Repo is canonical for engineering docs

- **Status:** Accepted
- **Deciders:** Engineering
- **Date:** 2026-05-15
- **Tags:** process, documentation, tooling

## Context and Problem Statement

Big Health's engineering team has historically used Confluence as the primary documentation surface. PRDs, TDDs, and ADRs have all been authored there. Engineering is now adopting AI-assisted authoring workflows (Claude Code) and a PR-based review discipline. We need to decide where engineering docs are authored and reviewed: in Confluence, in the repo, or both.

## Decision Drivers

- AI-assisted authoring works in the filesystem. Confluence via MCP is possible but high-latency per edit, which breaks the iterative authoring loop.
- PR-based review is strictly better than Confluence comments: threaded line comments, one-click suggest-a-change, formal approval as a merge gate with timestamp and author.
- Engineers should not maintain two copies of any document.
- Non-engineers (PM, design, clinical, ops) read in Confluence and should keep doing so.

## Considered Options

- Confluence-native: author and review in Confluence; repos hold code only.
- Repo-canonical with Confluence sync: author and review in the repo; sync to Confluence as a read-only mirror.
- Dual-authoritative: maintain both surfaces independently.

## Decision Outcome

Chosen option: **"Repo-canonical with Confluence sync"**, because it preserves AI-assisted authoring speed and PR-based review discipline while keeping Confluence as the read surface non-engineers already use.

### Positive Consequences

- Iterative AI-assisted authoring is fast (no MCP round-trips per edit).
- Reviews happen in GitHub with line comments, suggest-a-change, and merge as the formal approval gate.
- Single source of truth: the repo. Confluence is a derived view.

### Negative Consequences

- Risk that someone edits a Confluence page directly and creates drift. Mitigated by norm ("raise a PR") and, eventually, by sync overwrite or drift detection.
- The sync itself must be built and maintained.
- Engineers must learn two surfaces (argus and project repos), though they have distinct jobs.

## Pros and Cons of the Options

### Confluence-native

- Good, because non-engineers already author and read there.
- Bad, because AI-assisted authoring becomes painfully slow.
- Bad, because Confluence review UX (page comments, no merge gate, weak history) is materially worse than PR review.

### Repo-canonical with Confluence sync

- Good, because authoring and review happen where the rest of engineering work happens.
- Good, because formal approval is a merge gate, not a comment thread.
- Good, because Confluence remains the read surface for non-engineers.
- Bad, because the sync must be built; until then, Confluence reference is manual.
- Bad, because direct Confluence edits can cause drift.

### Dual-authoritative

- Bad, because two surfaces drift by default and reconciling them is unbounded work.

## Links

- [Engineering handbook — Section 4: Rationale](../process/engineering-handbook.md#section-4-rationale)
- [ADR-0001: Use MADR format for ADRs](ADR-0001-use-madr-format.md)
