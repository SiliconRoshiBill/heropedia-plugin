#!/usr/bin/env bash
# ============================================================================
# Heropedia — Codex installer
#
# Registers the Heropedia MCP server in your ~/.codex/config.toml and installs
# the AGENTS.md workflow file (if requested) so Codex sessions know how to
# consult the 324+ expert personas at https://www.heropedia.org/mcp.
#
# Safe to re-run. Backs up your existing config before making any change.
#
# Usage:
#   curl -sSL https://www.heropedia.org/codex/install-codex.sh | bash
#   curl -sSL https://www.heropedia.org/codex/install-codex.sh | bash -s -- --with-agents
#   ./install-codex.sh              # local run
#   ./install-codex.sh --with-agents # also install AGENTS.md into ~/.codex/AGENTS.md
# ============================================================================

set -eu

CODEX_DIR="${CODEX_HOME:-$HOME/.codex}"
CONFIG_PATH="$CODEX_DIR/config.toml"
AGENTS_PATH="$CODEX_DIR/AGENTS.md"
BACKUP_TS=$(printf '%s' "$(date +%Y%m%d-%H%M%S 2>/dev/null || echo backup)")
MCP_URL="https://www.heropedia.org/mcp"
# AGENTS.md lives in the plugin repo (public) — served raw over GitHub.
AGENTS_URL="https://raw.githubusercontent.com/SiliconRoshiBill/heropedia-plugin/main/codex/AGENTS.md"

WITH_AGENTS=0
for arg in "$@"; do
  case "$arg" in
    --with-agents) WITH_AGENTS=1 ;;
    --help|-h)
      grep '^#' "$0" | sed 's/^# \{0,1\}//'
      exit 0
      ;;
  esac
done

say()  { printf '\033[36m[heropedia]\033[0m %s\n' "$*"; }
warn() { printf '\033[33m[heropedia] warning:\033[0m %s\n' "$*" >&2; }
die()  { printf '\033[31m[heropedia] error:\033[0m %s\n' "$*" >&2; exit 1; }

# ---------------------------------------------------------------------------
# 1. Prepare ~/.codex/ and detect existing state
# ---------------------------------------------------------------------------
mkdir -p "$CODEX_DIR"

if [ -f "$CONFIG_PATH" ]; then
  if grep -qE '^\[mcp_servers\.heropedia\]' "$CONFIG_PATH"; then
    say "Heropedia MCP is already registered in $CONFIG_PATH. Nothing to change."
    ALREADY_REGISTERED=1
  else
    ALREADY_REGISTERED=0
  fi
else
  ALREADY_REGISTERED=0
fi

# ---------------------------------------------------------------------------
# 2. Add the MCP block if missing
# ---------------------------------------------------------------------------
if [ "$ALREADY_REGISTERED" -eq 0 ]; then
  if [ -f "$CONFIG_PATH" ]; then
    cp "$CONFIG_PATH" "$CONFIG_PATH.$BACKUP_TS.bak"
    say "Backed up existing config to $CONFIG_PATH.$BACKUP_TS.bak"
  fi

  {
    if [ -f "$CONFIG_PATH" ]; then
      cat "$CONFIG_PATH"
      # Ensure trailing newline before appending.
      tail -c 1 "$CONFIG_PATH" | od -An -c | grep -q '\\n' || echo ""
      echo ""
    fi
    echo "# --- Heropedia MCP (installed $(date -u +%Y-%m-%d 2>/dev/null || echo unknown)) ---"
    echo "# 324+ expert personas: https://www.heropedia.org"
    echo "[mcp_servers.heropedia]"
    echo "url = \"$MCP_URL\""
  } > "$CONFIG_PATH.tmp"

  mv "$CONFIG_PATH.tmp" "$CONFIG_PATH"
  say "Registered heropedia MCP in $CONFIG_PATH"
fi

# ---------------------------------------------------------------------------
# 3. Optional: install AGENTS.md
# ---------------------------------------------------------------------------
if [ "$WITH_AGENTS" -eq 1 ]; then
  if [ -f "$AGENTS_PATH" ] && grep -q 'Heropedia — agent instructions' "$AGENTS_PATH" 2>/dev/null; then
    say "AGENTS.md already contains heropedia workflow. Nothing to change."
  else
    if [ -f "$AGENTS_PATH" ]; then
      cp "$AGENTS_PATH" "$AGENTS_PATH.$BACKUP_TS.bak"
      say "Backed up existing AGENTS.md to $AGENTS_PATH.$BACKUP_TS.bak"
    fi

    if command -v curl >/dev/null 2>&1; then
      HTTP_CODE=$(curl -sSL -o "$AGENTS_PATH.new" -w '%{http_code}' "$AGENTS_URL" || echo 000)
      [ "$HTTP_CODE" = "200" ] || die "Fetch $AGENTS_URL returned HTTP $HTTP_CODE"
    elif command -v wget >/dev/null 2>&1; then
      wget -q "$AGENTS_URL" -O "$AGENTS_PATH.new" || die "Could not fetch $AGENTS_URL"
    else
      die "Need curl or wget to fetch AGENTS.md"
    fi
    # Sanity check: file must contain the expected header, not an error page or homepage HTML.
    if ! head -3 "$AGENTS_PATH.new" | grep -q 'Heropedia — agent instructions'; then
      rm -f "$AGENTS_PATH.new"
      die "Downloaded AGENTS.md did not match expected content (got redirected or wrong URL)."
    fi

    if [ -f "$AGENTS_PATH" ]; then
      {
        cat "$AGENTS_PATH"
        echo ""
        echo "---"
        echo ""
        cat "$AGENTS_PATH.new"
      } > "$AGENTS_PATH.merged"
      mv "$AGENTS_PATH.merged" "$AGENTS_PATH"
      rm -f "$AGENTS_PATH.new"
      say "Appended heropedia workflow to $AGENTS_PATH"
    else
      mv "$AGENTS_PATH.new" "$AGENTS_PATH"
      say "Installed $AGENTS_PATH"
    fi
  fi
fi

# ---------------------------------------------------------------------------
# 4. Report
# ---------------------------------------------------------------------------
echo ""
say "Done. Start a new Codex session and try:"
say "  \"Ask Warren Buffett to review my pitch deck.\""
say "  \"Consult Charlie Munger on this decision.\""
say ""
say "Uninstall by removing the [mcp_servers.heropedia] block from $CONFIG_PATH"
if [ "$WITH_AGENTS" -eq 1 ]; then
  say "(and the Heropedia section from $AGENTS_PATH if you added --with-agents)"
fi
