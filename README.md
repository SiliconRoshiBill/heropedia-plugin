# Heropedia Plugin for Claude Code

Consult 324+ hand-crafted expert personas — Warren Buffett, Steve Jobs, Charlie Munger, Linus Torvalds, and more — directly from any Claude Code session.

This plugin bundles:

- **`heropedia` skill** — triggers on phrases like *"ask <name> to..."*, *"consult <name>"*, *"channel <name>"*. Fetches the canonical persona prompt from Heropedia MCP before answering, so the reply is truly through that expert's lens (not an impression of it).
- **`.mcp.json`** — registers `https://www.heropedia.org/mcp` as an MCP server so Claude Code can call `getList`, `getListByHero`, `getListByRole`, and `getDetail`.

The plugin does not ship any data. All 324+ personas live at [heropedia.org](https://www.heropedia.org) and are fetched on demand.

## Install

Two commands. The first registers this repo as a marketplace; the second installs the plugin from it.

```bash
claude plugin marketplace add https://github.com/SiliconRoshiBill/heropedia-plugin
claude plugin install heropedia@heropedia
```

That's it. The plugin auto-registers the MCP server (`plugin:heropedia:heropedia`) on install — no separate `claude mcp add` needed. Open a new session and you're wired up.

## Try it

Once installed, just ask:

> "Ask Warren Buffett to review my SaaS pricing page."
> "As Steve Jobs, tear apart this landing page."
> "Consult Charlie Munger on this go/no-go decision."
> "What would Linus Torvalds say about this refactor?"
> "Get a product critic to look at this feature spec."

Claude will:
1. Recognize the persona intent.
2. Call `mcp__heropedia__getListByHero` to find the entry.
3. Call `mcp__heropedia__getDetail` to fetch the canonical prompt.
4. Answer through that persona's lens.

If a name maps to multiple roles (e.g. Warren Buffett as investor vs. business analyst), Claude asks which lens fits your task before answering.

## What's inside

```
heropedia-plugin/
├── .claude-plugin/
│   └── plugin.json          # plugin manifest
├── .mcp.json                # MCP server registration
├── skills/
│   └── heropedia/
│       └── SKILL.md         # workflow enforcement skill
└── README.md
```

## Requirements

- Claude Code (any recent version).
- Internet access — the MCP server is hosted at `https://www.heropedia.org/mcp`.
- Nothing else. No API key. No account. Public endpoint, IP-rate-limited (300 req/min list, 60 req/min detail).

## The MCP endpoint

Public HTTP MCP server at `https://www.heropedia.org/mcp` speaking [MCP 2025-06-18 Streamable HTTP](https://modelcontextprotocol.io/specification/2025-06-18/basic/transports). Four read-only tools:

| Tool | Purpose |
|---|---|
| `getList` | Paginated catalog of every hero × role entry |
| `getListByHero` | Filter by hero name (regex, case-insensitive, safe grammar) |
| `getListByRole` | Filter by role name (same regex rules) |
| `getDetail` | Full canonical markdown for one entry |

Returns lightweight metadata (`{id, hero_name, role_name, description}`) from LIST tools; only `getDetail` returns the full persona prompt.

User guide with install snippets, examples, and FAQ: [heropedia.org/mcp-guide](https://www.heropedia.org/mcp-guide)

## Uninstall

```bash
claude plugin uninstall heropedia
```

## License

MIT. See [`LICENSE`](./LICENSE).

The persona content at heropedia.org is separately MIT-licensed in the [`SiliconRoshiBill/heropedia`](https://github.com/SiliconRoshiBill/heropedia) content repo.

## Contribute a new hero

Anyone with a GitHub account can. Submit at [heropedia.org/submit](https://www.heropedia.org/submit). The community votes on the best versions.
