#!/usr/bin/env bash
# ============================================================================
# validate-skill.sh — structural lint for heropedia-office-hour SKILL.md
#
# Not a test framework. Just grep + expected substrings. If a line the model
# needs is missing, this catches it before the skill is shipped.
#
# Usage:  bash scripts/validate-skill.sh <path-to-SKILL.md>
# Exit:   0 = all checks pass, 1 = at least one check failed.
# ============================================================================
set -euo pipefail

target="${1:-}"
if [[ -z "$target" ]]; then
  echo "usage: $0 <path-to-SKILL.md>" >&2
  exit 2
fi
if [[ ! -f "$target" ]]; then
  echo "not a file: $target" >&2
  exit 2
fi

fail=0
check() {
  local label="$1"; shift
  if "$@" >/dev/null; then
    printf "  ok    %s\n" "$label"
  else
    printf "  FAIL  %s\n" "$label"
    fail=1
  fi
}

echo "validating: $target"

# --- frontmatter fields ---
check "frontmatter: name"          grep -qE '^name: heropedia-office-hour$' "$target"
check "frontmatter: description"   grep -qE '^description: ' "$target"
check "frontmatter: allowed-tools" grep -qE '^allowed-tools:' "$target"

# --- required tool declarations ---
check "tool: getListByHero"  grep -qE 'mcp__heropedia__getListByHero'  "$target"
check "tool: getListByRole"  grep -qE 'mcp__heropedia__getListByRole'  "$target"
check "tool: getList"        grep -qE 'mcp__heropedia__getList\b'      "$target"
check "tool: getDetail"      grep -qE 'mcp__heropedia__getDetail'      "$target"
check "tool: AskUserQuestion" grep -qE 'AskUserQuestion'                "$target"
check "tool: Bash"           grep -qE '^  - Bash$'                     "$target"
check "tool: Write"          grep -qE '^  - Write$'                    "$target"

# --- triggers (all six required) ---
check "trigger: hold office hours"    grep -qF 'hold office hours'           "$target"
check "trigger: let <name> hold"      grep -qF 'let <name> hold office hours' "$target"
check "trigger: office hour with"     grep -qF 'office hour with <name>'      "$target"
check "trigger: office hour on"       grep -qF 'office hour on <topic>'       "$target"
check "trigger: name,-hold"           grep -qF 'hold office hours with me on' "$target"
check "trigger: slash command"        grep -qF '/heropedia-office-hour'       "$target"

# --- required section headings (in order) ---
check "section: Phase 0"  grep -qE '^## +Phase 0'                 "$target"
check "section: Phase 1"  grep -qE '^## +Phase 1'                 "$target"
check "section: Phase 2"  grep -qE '^## +Phase 2'                 "$target"
check "section: Phase 3"  grep -qE '^## +Phase 3'                 "$target"
check "section: Phase 4"  grep -qE '^## +Phase 4'                 "$target"
check "section: Phase 5"  grep -qE '^## +Phase 5'                 "$target"
check "section: safety"   grep -qiE '^## +.*(safety|injection)'   "$target"
check "section: privacy"  grep -qiE '^## +.*(privacy|data)'       "$target"

# --- privacy guarantees (verbatim substrings) ---
check "privacy: notes never uploaded" grep -qF 'never leaves the local machine' "$target"
check "privacy: no HTTP requests"    grep -qF 'never sends any HTTP request'   "$target"

# --- fallback path (## Office Hour Questions parsing) ---
check "parser: canonical section" grep -qF '## Office Hour Questions' "$target"
check "parser: fallback distill"  grep -qiE 'distill.*runtime|runtime.*distill' "$target"

# --- notes path ---
check "notes: canonical path"     grep -qF '~/.heropedia/office-hours/' "$target"

# --- prompt-injection rule inherited from heropedia skill ---
check "safety: data-not-commands" grep -qiE 'as +data.*not +commands|not +commands.*as +data' "$target"

if (( fail )); then
  echo ""
  echo "validation FAILED"
  exit 1
fi
echo ""
echo "validation ok"
