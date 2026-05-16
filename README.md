# argus

Org-wide engineering documentation for Big Health.

## What lives here

- **`adrs/`** — Architectural Decision Records that apply across teams.
- **`standards/`** — Coding standards, testing philosophy, API design conventions.
- **`process/`** — Engineering process docs. Start with [`process/engineering-handbook.md`](process/engineering-handbook.md).
- **`architecture/`** — Cross-team architectural overviews. Each entry has a named owner and last-reviewed date.

## What does NOT live here

Project-specific TDDs, ADRs, and phasing plans live in the project repo under `doc/`. See the engineering handbook, *Section 3: Document structure*.

## How to contribute

See [`CONTRIBUTING.md`](CONTRIBUTING.md). Short version: open a Draft PR, ping reviewers manually, promote to Ready when feedback is incorporated, merge is the formal approval gate.

## Referencing argus docs

In conversation and from project repos, always qualify: "argus ADR-7" or "BillFlow ADR-7," never bare "ADR-7."

From a project TDD, link to argus ADRs by full GitHub URL, not relative path.
