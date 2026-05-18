---
adr: ADR-use-madr-format
title: Use MADR format for ADRs
owners: [engineering]
status: accepted
---

# Use MADR format for ADRs

- **Status:** Accepted
- **Deciders:** Engineering
- **Date:** 2026-05-15
- **Tags:** process, documentation

## Context and Problem Statement

We need a consistent format for Architectural Decision Records across argus and project repos. Without a shared format, ADRs drift toward inconsistent structure, make cross-repo review harder, and lose the discipline of recording what was considered and rejected.

## Decision Drivers

- Low authoring friction — engineers should reach for an ADR rather than avoid it.
- Reviewer-friendly — a reviewer who has never seen the decision should be able to evaluate it in one read.
- Captures alternatives, not just the chosen path — the value of an ADR is largely in what it records about options that were rejected.
- Widely recognized — engineers joining from other organizations should not need to learn a bespoke format.

## Considered Options

- MADR (Markdown Any Decision Records)
- Michael Nygard's original lightweight ADR template
- A custom Big Health template

## Decision Outcome

Chosen option: **"MADR"**, because it is the most widely adopted modern ADR format, explicitly records decision drivers and considered options (which Nygard's original treats more loosely), and remains lightweight enough for routine use.

### Positive Consequences

- Single shared format across argus and every project repo.
- New engineers recognize the structure immediately.
- Templates and tooling can target one format.

### Negative Consequences

- Slightly more boilerplate than Nygard's original for very small decisions.

## Pros and Cons of the Options

### MADR

- Good, because it is widely adopted and recognizable.
- Good, because it explicitly captures alternatives and decision drivers.
- Good, because it has a maintained template at [adr.github.io/madr](https://adr.github.io/madr/).
- Bad, because the template is slightly verbose for trivial decisions.

### Nygard's original

- Good, because it is the most lightweight ADR format.
- Bad, because it does not enforce capturing alternatives — the part of an ADR with the most long-term value.

### Custom Big Health template

- Bad, because it imposes a learning cost on new engineers for no apparent benefit.
- Bad, because we would have to maintain the template ourselves.

## Links

- [MADR project](https://adr.github.io/madr/)
- [`adr-template.md`](../../../templates/adr-template.md)
- [Repo is canonical for engineering docs](ADR-repo-canonical-for-engineering-docs.md)
