---
tdd: TDD-[slug]                  # canonical ID, must match filename
title: {Short title}
epic: BL-NNNN                    # primary Jira epic; null while in draft
related_epics: []                # optional, for cross-cutting work
related_areas: []                # optional, kebab-case area slugs
owners: [team-slug]
status: draft                    # draft | accepted | superseded
superseded_by:                   # slug of replacement TDD, only if status=superseded
---

# {Short title}

- **Status:** {Draft | Accepted | Superseded by [TDD-replacement](TDD-replacement.md)}
- **Deciders:** {names or team}
- **Date:** {YYYY-MM-DD}
- **Tags:** {comma-separated, optional}

## Summary

{One paragraph. What is this design and why does it matter? A reader should be able to stop here and have an accurate picture.}

## Context

{What is the existing system or situation? What problem are we solving? Link to PRDs, prior TDDs, ADRs, or tickets.}

## Goals and Non-Goals

**Goals**

- {Goal 1}
- {Goal 2}

**Non-Goals**

- {Out-of-scope item 1}

## Design

{Architecture, data flow, interfaces. Diagrams welcome.}

### Data Model

{Schemas, types, persistence.}

### APIs and Interfaces

{Surface area: HTTP, events, function signatures.}

### Sequence / State

{Sequence diagrams, state machines, or prose walkthroughs of key flows.}

## Decisions and Alternatives

{Each non-obvious decision below. Significant decisions warrant a standalone ADR — link from here.}

### {Decision 1}

- **Considered:** {options}
- **Chosen:** {option, because ...}
- {Link to standalone ADR, if any}

### {Decision 2}

- **Considered:** {options}
- **Chosen:** {option, because ...}

## Test Plan

- {Unit / integration coverage strategy}
- {End-to-end or acceptance scenarios}
- {What can't be tested and why}

## Risks and Open Questions

- {Risk or open question 1}
- {Risk or open question 2}

## Rollout

{How does this get deployed? Migration steps, feature flags, gradual rollout, backfills.}

## Links

- {Related TDDs, ADRs, PRDs, tickets, external references}
