#!/usr/bin/env bash
# Render the TDD registry from JSON inputs to markdown + JSON outputs.
#
# Usage:
#   render-registry.sh <entries.json> <errors.json>
#
# Inputs (each a JSON array on disk):
#   entries.json — array of TDD entries with fields:
#     tdd, title, status, owners, repo, path, url,
#     epic (optional), related_epics (optional), superseded_by (optional)
#   errors.json — array of parse/validation errors with fields:
#     repo, path, problem
#
# Outputs (written to $OUT_DIR, default doc/):
#   tdd-registry.md   — human-readable, sectioned by status, errors at the bottom
#   tdd-registry.json — { generated_at, entries[], errors[] }
#
# Environment overrides:
#   OUT_DIR        — output directory (default: doc)
#   JIRA_BASE      — Jira browse URL prefix (default: https://bighealth.atlassian.net/browse)
#
# Note: outputs deliberately omit a generation timestamp. The workflow diffs
# committed artifacts against main to decide whether to open a PR, so any
# always-changing field would create daily PR noise. Use `git log` on the
# artifacts for the last-changed date.

set -euo pipefail

if [ $# -ne 2 ]; then
  echo "usage: $0 <entries.json> <errors.json>" >&2
  exit 64
fi

ENTRIES=$1
ERRORS=$2
OUT_DIR=${OUT_DIR:-doc}
JIRA_BASE=${JIRA_BASE:-https://bighealth.atlassian.net/browse}

mkdir -p "$OUT_DIR"

# JSON sidecar: simple wrap of the inputs.
jq -n \
  --slurpfile entries "$ENTRIES" \
  --slurpfile errors  "$ERRORS" \
  '{entries: $entries[0], errors: $errors[0]}' \
  > "$OUT_DIR/tdd-registry.json"

total_entries=$(jq 'length' "$ENTRIES")
total_errors=$(jq 'length' "$ERRORS")

# Zero-state: no enrolled repos, or enrolled repos contribute zero TDDs and zero errors.
# Phasing plan §1: "Must work correctly with zero enrolled repos
# (registry exists, body is 'no TDDs registered')."
if [ "$total_entries" -eq 0 ] && [ "$total_errors" -eq 0 ]; then
  cat > "$OUT_DIR/tdd-registry.md" <<'MD'
# TDD registry

**Auto-generated.** Do not edit by hand. Source: `.github/workflows/regenerate-tdd-registry.yml`.

No TDDs registered. To enroll a repo, add it to `config/tdd-repos.yaml`.
MD
  exit 0
fi

# Reusable jq filter: escape | so titles with pipes don't break table rows.
mdescape='def mdescape: tostring | gsub("\\|"; "\\|");'

{
  echo "# TDD registry"
  echo
  echo "**Auto-generated.** Do not edit by hand. Source: \`.github/workflows/regenerate-tdd-registry.yml\`."

  for status in accepted draft superseded; do
    section_title=$(printf '%s' "$status" | awk '{print toupper(substr($0,1,1)) substr($0,2)}')
    echo
    echo "## $section_title"
    echo

    rows=$(jq -r \
      --arg s "$status" \
      --arg jira "$JIRA_BASE" \
      "$mdescape "'
        map(select(.status == $s))
        | sort_by(.repo, .title)
        | .[]
        | "| "
          + ( if .epic and (.epic | length) > 0
              then "[" + (.epic | mdescape) + "](" + $jira + "/" + (.epic | tostring) + ")"
              else "—"
              end )
          + " | [" + (.tdd | mdescape) + "](" + .url + ")"
          + " | " + ((.title // "—") | mdescape)
          + " | " + ((.repo // "—") | mdescape)
          + " | " + (((.owners // []) | map(mdescape) | join(", ")))
          + " |"
      ' "$ENTRIES")

    if [ -n "$rows" ]; then
      echo "| Epic | TDD | Title | Repo | Owners |"
      echo "|---|---|---|---|---|"
      printf '%s\n' "$rows"
    else
      echo "_(no $status TDDs)_"
    fi
  done

  echo
  echo "## Errors"
  echo

  err_rows=$(jq -r "$mdescape "'
    sort_by(.repo, .path)
    | .[]
    | "| " + ((.repo    // "—") | mdescape)
      + " | " + ((.path    // "—") | mdescape)
      + " | " + ((.problem // "—") | mdescape)
      + " |"
  ' "$ERRORS")

  if [ -n "$err_rows" ]; then
    echo "| Repo | Path | Problem |"
    echo "|---|---|---|"
    printf '%s\n' "$err_rows"
  else
    echo "_(none)_"
  fi
} > "$OUT_DIR/tdd-registry.md"
