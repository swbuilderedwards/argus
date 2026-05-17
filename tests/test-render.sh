#!/usr/bin/env bash
# Local test for the TDD registry generator.
# Runs scripts/regenerate-tdd-registry.sh against tests/fixtures/repos/ and
# asserts the resulting JSON sidecar matches what we expect.
#
# Usage:
#   ./tests/test-render.sh
#
# Requires: jq, yq, bash 4+.
# Does NOT require gh or network access (uses LOCAL_FIXTURES_DIR mode).

set -euo pipefail

REPO_ROOT=$(cd "$(dirname "$0")/.." && pwd)
cd "$REPO_ROOT"

FAILED=0
TMPDIRS=()
# bash 3.2 (macOS default) mishandles "${arr[@]}" under set -u; gate on length.
trap '[ ${#TMPDIRS[@]} -gt 0 ] && rm -rf "${TMPDIRS[@]}" || true' EXIT

pass() { printf '  \033[32m✓\033[0m %s\n' "$1"; }
fail() { printf '  \033[31m✗\033[0m %s\n' "$1"; FAILED=$((FAILED + 1)); }

# Run the generator against $2 (fixtures dir), write outputs into a fresh temp
# dir, and echo the temp dir path on stdout. All other output goes to stderr so
# capture is clean.
run_case() {
  local name=$1 fixtures=$2
  echo                                          >&2
  echo "Case: $name"                            >&2

  local out
  out=$(mktemp -d)
  TMPDIRS+=("$out")

  if OUT_DIR="$out" \
     LOCAL_FIXTURES_DIR="$fixtures" \
     ./scripts/regenerate-tdd-registry.sh >/dev/null 2>"$out/stderr.log"
  then :
  else
    fail "generator exited non-zero (see $out/stderr.log)" >&2
    cat "$out/stderr.log" >&2
    echo "$out"
    return
  fi

  { [ -f "$out/tdd-registry.md"   ] && pass "wrote tdd-registry.md"   || fail "missing tdd-registry.md";   } >&2
  { [ -f "$out/tdd-registry.json" ] && pass "wrote tdd-registry.json" || fail "missing tdd-registry.json"; } >&2

  { jq empty "$out/tdd-registry.json" 2>/dev/null \
      && pass "tdd-registry.json is valid JSON" \
      || fail "tdd-registry.json is invalid JSON"; } >&2

  echo "$out"
}

# --- Case 1: rich fixture tree ---
case1_out=$(run_case "rich fixture tree" "$REPO_ROOT/tests/fixtures/repos")

n_entries=$(jq '.entries | length' "$case1_out/tdd-registry.json")
n_errors=$(jq  '.errors  | length' "$case1_out/tdd-registry.json")

[ "$n_entries" = "3" ] \
  && pass "3 valid entries"                       \
  || fail "expected 3 entries, got $n_entries"

[ "$n_errors" = "3" ] \
  && pass "3 errors"                              \
  || fail "expected 3 errors, got $n_errors"

# Validate that the expected TDDs are present in entries
for slug in TDD-claims-validator TDD-eligibility-flow TDD-legacy-auth; do
  found=$(jq -r --arg s "$slug" '.entries[] | select(.tdd == $s) | .tdd' "$case1_out/tdd-registry.json")
  [ "$found" = "$slug" ] \
    && pass "entry: $slug"                        \
    || fail "missing entry: $slug"
done

# Validate that the expected errors are present
for substring in "epic.*missing" "unparseable YAML" "missing or malformed .tdd:"; do
  if jq -r '.errors[] | .problem' "$case1_out/tdd-registry.json" | grep -qE "$substring"; then
    pass "error reported: matches /$substring/"
  else
    fail "expected an error matching /$substring/"
  fi
done

# README.md and template.md must NOT contribute rows
if jq -e '.entries[] | select(.path | endswith("README.md") or endswith("template.md"))' \
      "$case1_out/tdd-registry.json" >/dev/null; then
  fail "README/template files leaked into entries"
else
  pass "README files filtered out"
fi

# Status sections appear in the rendered markdown
for header in "## Accepted" "## Draft" "## Superseded" "## Errors"; do
  grep -qF "$header" "$case1_out/tdd-registry.md" \
    && pass "section present: $header" \
    || fail "section missing: $header"
done

# Jira link for the accepted TDD
grep -qF "[BL-1234](https://bighealth.atlassian.net/browse/BL-1234)" "$case1_out/tdd-registry.md" \
  && pass "Jira link rendered for BL-1234" \
  || fail "Jira link missing for BL-1234"

# GitHub link for the accepted TDD
grep -qF "https://github.com/Big-Health/sample-repo/blob/main/doc/tdds/TDD-claims-validator.md" \
      "$case1_out/tdd-registry.md" \
  && pass "GitHub link rendered for TDD-claims-validator" \
  || fail "GitHub link missing for TDD-claims-validator"

# --- Case 2: zero-state (empty fixtures dir) ---
empty_fixtures=$(mktemp -d)
case2_out=$(run_case "zero-state (empty fixtures dir)" "$empty_fixtures")
rmdir "$empty_fixtures"

n_entries=$(jq '.entries | length' "$case2_out/tdd-registry.json")
n_errors=$(jq  '.errors  | length' "$case2_out/tdd-registry.json")

[ "$n_entries" = "0" ] && pass "zero entries" || fail "expected 0 entries, got $n_entries"
[ "$n_errors"  = "0" ] && pass "zero errors"  || fail "expected 0 errors, got $n_errors"

grep -qF "No TDDs registered" "$case2_out/tdd-registry.md" \
  && pass "zero-state body rendered" \
  || fail "zero-state body missing"

# --- Summary ---
echo
if [ "$FAILED" -eq 0 ]; then
  printf '\033[32mAll checks passed.\033[0m\n'
  exit 0
else
  printf '\033[31m%d check(s) failed.\033[0m\n' "$FAILED"
  exit 1
fi
