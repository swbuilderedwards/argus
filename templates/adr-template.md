---
adr: ADR-[slug]                  # canonical ID, must match filename
title: {Short title}
owners: [team-slug]              # owning team(s)
status: proposed                 # proposed | accepted | superseded
supersedes: []                   # list of ADR slugs, optional
superseded_by:                   # slug of replacement ADR, only if status=superseded
---

# {Short title}

- **Status:** {Proposed | Accepted | Superseded by [ADR-replacement](ADR-replacement.md)}
- **Deciders:** {names or team}
- **Date:** {YYYY-MM-DD}
- **Tags:** {comma-separated, optional}

## Context and Problem Statement

{Two or three sentences. What is the situation, and what are we deciding? A question form often works well.}

## Decision Drivers

- {driver 1 — a force, constraint, or quality attribute that matters}
- {driver 2}
- {driver 3}

## Considered Options

- {Option 1}
- {Option 2}
- {Option 3}

## Decision Outcome

Chosen option: **"{Option N}"**, because {justification — meets a k.o. criterion, resolves the strongest driver, etc.}.

### Positive Consequences

- {what gets better}

### Negative Consequences

- {what gets worse or what we now have to handle}

## Pros and Cons of the Options

### {Option 1}

{Description or link.}

- Good, because {argument}
- Good, because {argument}
- Bad, because {argument}

### {Option 2}

{Description or link.}

- Good, because {argument}
- Bad, because {argument}

### {Option 3}

{Description or link.}

- Good, because {argument}
- Bad, because {argument}

## Links

- {Related ADR, TDD, RFC, ticket, or external reference}
