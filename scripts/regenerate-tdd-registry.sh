#!/usr/bin/env bash
# Regenerate the TDD registry by scanning enrolled repos for TDD files,
# parsing their frontmatter, validating against the contract, and writing
# doc/tdd-registry.md and doc/tdd-registry.json via the renderer.
#
# Modes:
#   Default (GitHub): authenticates via $GH_TOKEN, reads enrolled repos from
#     $CONFIG_FILE, fetches files via the GitHub Contents API.
#   Local fixtures: set $LOCAL_FIXTURES_DIR to a directory laid out as
#     <fixtures>/<org>/<repo>/doc/tdds/TDD-*.md and the script reads from
#     disk instead. Used by tests/test-render.sh.
#
# Environment:
#   CONFIG_FILE         (default config/tdd-repos.yaml)
#   OUT_DIR             (default doc)
#   JIRA_BASE           (default https://bighealth.atlassian.net/browse)
#   LOCAL_FIXTURES_DIR  (if set, skips gh API and reads from disk)
#
# Dependencies: bash 4+, gh, jq, yq, awk.

set -euo pipefail

CONFIG_FILE=${CONFIG_FILE:-config/tdd-repos.yaml}
OUT_DIR=${OUT_DIR:-doc}
JIRA_BASE=${JIRA_BASE:-https://bighealth.atlassian.net/browse}
LOCAL_FIXTURES_DIR=${LOCAL_FIXTURES_DIR:-}

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
ENTRIES_JSONL="$TMP/entries.jsonl"
ERRORS_JSONL="$TMP/errors.jsonl"
: > "$ENTRIES_JSONL"
: > "$ERRORS_JSONL"

emit_error() {
  local repo=$1 path=$2 problem=$3
  jq -nc \
    --arg r "$repo" --arg p "$path" --arg pr "$problem" \
    '{repo:$r, path:$p, problem:$pr}' \
    >> "$ERRORS_JSONL"
}

# Parse, validate, and emit one TDD file.
#   $1 repo  — Big-Health/<repo>
#   $2 path  — doc/tdds/TDD-foo.md
#   $3 raw   — file contents
process_file() {
  local repo=$1 path=$2 raw=$3

  # Extract YAML between the first two '---' delimiter lines.
  local fm
  fm=$(printf '%s' "$raw" | awk '
    BEGIN { in_fm = 0; done = 0 }
    /^---[[:space:]]*$/ && done == 0 {
      if (in_fm) { done = 1; next } else { in_fm = 1; next }
    }
    in_fm && done == 0 { print }
  ')

  if [ -z "$fm" ]; then
    emit_error "$repo" "$path" "no YAML frontmatter found"
    return
  fi

  local fm_json
  if ! fm_json=$(printf '%s' "$fm" | yq -o=json -p=yaml '.' 2>/dev/null); then
    emit_error "$repo" "$path" "unparseable YAML frontmatter"
    return
  fi

  # Compose the entry, then validate.
  local entry
  entry=$(jq -c \
    --arg repo "$repo" \
    --arg path "$path" \
    --arg url  "https://github.com/$repo/blob/main/$path" \
    '{
       tdd: .tdd,
       title: .title,
       status: .status,
       epic: (.epic // null),
       related_epics: (.related_epics // []),
       owners: (.owners // []),
       superseded_by: (.superseded_by // null),
       repo: $repo,
       path: $path,
       url: $url
     }' <<<"$fm_json")

  local problems
  problems=$(jq -r '
    [
      ( if (.tdd // "" | tostring | test("^TDD-[a-z0-9-]+$"))
        then empty
        else "missing or malformed `tdd:` (must match TDD-[a-z0-9-]+)"
        end ),
      ( if (.title // "" | tostring | length) > 0
        then empty
        else "missing `title:`"
        end ),
      ( (.status // "" | tostring) as $s
        | if $s == "draft" or $s == "accepted" or $s == "superseded"
          then empty
          else "`status:` must be one of draft, accepted, superseded"
          end ),
      ( if .status == "accepted" and ((.epic // "" | tostring) == "")
        then "status is `accepted` but `epic:` is missing"
        else empty
        end ),
      ( if .status == "superseded" and ((.superseded_by // "" | tostring) == "")
        then "status is `superseded` but `superseded_by:` is missing"
        else empty
        end ),
      ( if (.owners | type) == "array" and (.owners | length) > 0
        then empty
        else "missing `owners:` (must be a non-empty list)"
        end )
    ] | join("; ")
  ' <<<"$entry")

  if [ -n "$problems" ]; then
    emit_error "$repo" "$path" "$problems"
    return
  fi

  echo "$entry" >> "$ENTRIES_JSONL"
}

# ---- Source: GitHub API ----
scan_via_gh() {
  if [ ! -f "$CONFIG_FILE" ]; then
    echo "Config file $CONFIG_FILE not found." >&2
    exit 1
  fi

  local repos
  repos=$(yq -r '.repos[]?.name' "$CONFIG_FILE")

  if [ -z "$repos" ]; then
    echo "No repos enrolled in $CONFIG_FILE." >&2
    return
  fi

  while IFS= read -r repo; do
    [ -z "$repo" ] && continue
    echo "Scanning $repo..." >&2

    local err_file="$TMP/gh-err.$$"
    local listing
    if listing=$(gh api --paginate "repos/$repo/contents/doc/tdds" 2>"$err_file"); then
      :
    elif grep -q '404' "$err_file"; then
      echo "  no doc/tdds/ in $repo, skipping" >&2
      rm -f "$err_file"
      continue
    else
      echo "ERROR fetching $repo contents:" >&2
      cat "$err_file" >&2
      rm -f "$err_file"
      exit 1
    fi
    rm -f "$err_file"

    # gh api --paginate concatenates arrays into multiple top-level arrays; slurp them.
    local paths
    paths=$(echo "$listing" \
      | jq -rs 'flatten | .[]? | select(.type=="file" and (.name | startswith("TDD-")) and (.name | endswith(".md"))) | .path')

    if [ -z "$paths" ]; then
      echo "  no TDD-*.md files in $repo/doc/tdds/, skipping" >&2
      continue
    fi

    while IFS= read -r p; do
      local raw
      raw=$(gh api "repos/$repo/contents/$p" --header 'Accept: application/vnd.github.raw')
      process_file "$repo" "$p" "$raw"
    done <<<"$paths"
  done <<<"$repos"
}

# ---- Source: local fixtures ----
scan_via_fixtures() {
  shopt -s nullglob
  local org_dir org repo_dir repo_name repo tdds_dir f rel raw
  for org_dir in "$LOCAL_FIXTURES_DIR"/*/; do
    org=$(basename "$org_dir")
    for repo_dir in "$org_dir"*/; do
      repo_name=$(basename "$repo_dir")
      repo="$org/$repo_name"
      tdds_dir="${repo_dir}doc/tdds"
      if [ ! -d "$tdds_dir" ]; then
        echo "  no doc/tdds/ in $repo (fixture), skipping" >&2
        continue
      fi
      for f in "$tdds_dir"/TDD-*.md; do
        [ -f "$f" ] || continue
        rel="doc/tdds/$(basename "$f")"
        raw=$(cat "$f")
        process_file "$repo" "$rel" "$raw"
      done
    done
  done
}

if [ -n "$LOCAL_FIXTURES_DIR" ]; then
  scan_via_fixtures
else
  scan_via_gh
fi

# Slurp JSONL → JSON array; empty file → [].
jq -s '.' "$ENTRIES_JSONL" > "$TMP/entries.json"
jq -s '.' "$ERRORS_JSONL"  > "$TMP/errors.json"

OUT_DIR="$OUT_DIR" JIRA_BASE="$JIRA_BASE" \
  "$SCRIPT_DIR/lib/render-registry.sh" "$TMP/entries.json" "$TMP/errors.json"

echo "Wrote $OUT_DIR/tdd-registry.md and $OUT_DIR/tdd-registry.json" >&2
