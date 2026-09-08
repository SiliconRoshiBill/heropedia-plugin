# Heropedia Plugin for Claude Code

Consult 324+ hand-crafted expert personas — Warren Buffett, Steve Jobs, Charlie Munger, Linus Torvalds, and more — directly from any Claude Code session.

This plugin bundles:

- **`heropedia` skill** — triggers on phrases like *"ask <name> to..."*, *"consult <name>"*, *"channel <name>"*. Fetches the canonical persona prompt from Heropedia MCP before answering, so the reply is truly through that expert's lens (not an impression of it).
- **`.mcp.json`** — registers `https://www.heropedia.org/mcp` as an MCP server so Claude Code can call `getList`, `getListByHero`, `getListByRole`, and `getDetail`.

The plugin does not ship any data. All 324+ personas live at [heropedia.org](https://www.heropedia.org) and are fetched on demand.

## Install

Pick your AI. Every path targets the same endpoint (`https://www.heropedia.org/mcp`).

### Anthropic — Claude Code (recommended)

```bash
claude plugin marketplace add https://github.com/SiliconRoshiBill/heropedia-plugin
claude plugin install heropedia@heropedia
```

Auto-registers the MCP server as `plugin:heropedia:heropedia`. Open a new session and you're wired up.

### Anthropic — Claude Desktop

Add to `claude_desktop_config.json`:

```json
{
  "mcpServers": {
    "heropedia": {
      "command": "npx",
      "args": ["-y", "mcp-remote", "https://www.heropedia.org/mcp"]
    }
  }
}
```

### OpenAI — ChatGPT (web / macOS / Windows apps)

Available on **Plus, Pro, Business, Enterprise, and Edu plans** (not Free / Team).

1. Settings → *Connectors* → Advanced → toggle *Developer mode* on.
2. Settings → *Connectors* → *Add custom connector*.
3. Paste MCP URL: `https://www.heropedia.org/mcp`
4. Auth: *No authentication*. Save.
5. Enable the *Heropedia* connector for chats where you want it.

Business/Enterprise workspaces: a workspace admin adds the connector under Workspace Settings → Connectors → New app.

### OpenAI — Codex (CLI)

```bash
curl -sSL https://raw.githubusercontent.com/SiliconRoshiBill/heropedia-plugin/main/codex/install-codex.sh | bash
```

Add `--with-agents` to also install the workflow-enforcing `AGENTS.md`:

```bash
curl -sSL https://raw.githubusercontent.com/SiliconRoshiBill/heropedia-plugin/main/codex/install-codex.sh | bash -s -- --with-agents
```

Or manually add to `~/.codex/config.toml`:

```toml
[mcp_servers.heropedia]
url = "https://www.heropedia.org/mcp"
```

### OpenAI — Agents SDK

**Python** (`openai-agents-python`):

```python
from agents import Agent, Runner
from agents.mcp import MCPServerStreamableHttp

async with MCPServerStreamableHttp(
    params={"url": "https://www.heropedia.org/mcp"},
    name="heropedia",
) as server:
    agent = Agent(
        name="ConsultantAgent",
        instructions=(
            "When the user asks to consult a specific expert, call "
            "getListByHero to find the entry, then getDetail to fetch "
            "the canonical prompt. Apply that persona — do not paraphrase."
        ),
        mcp_servers=[server],
    )
    result = await Runner.run(agent, "Ask Warren Buffett to review my pricing page.")
    print(result.final_output)
```

**TypeScript** (`@openai/agents`):

```ts
import { Agent, Runner } from "@openai/agents";
import { MCPServerStreamableHttp } from "@openai/agents/mcp";

const heropedia = new MCPServerStreamableHttp({
  url: "https://www.heropedia.org/mcp",
  name: "heropedia",
});

const agent = new Agent({
  name: "ConsultantAgent",
  instructions:
    "When the user asks to consult a specific expert, call getListByHero " +
    "to find the entry, then getDetail to fetch the canonical prompt. " +
    "Apply that persona — do not paraphrase.",
  mcpServers: [heropedia],
});

const result = await Runner.run(agent, "Ask Warren Buffett to review my pricing page.");
console.log(result.finalOutput);
```

### Google — Gemini CLI

This repo ships a [`gemini-extension.json`](./gemini-extension.json). Follow the [Gemini CLI extensions guide](https://geminicli.com/docs/extensions/) to add it, or paste this into your Gemini config:

```json
{
  "mcpServers": {
    "heropedia": {
      "httpUrl": "https://www.heropedia.org/mcp"
    }
  }
}
```

### Cursor

Add to your Cursor MCP config file:

```json
{
  "mcpServers": {
    "heropedia": {
      "url": "https://www.heropedia.org/mcp"
    }
  }
}
```

### Any HTTP MCP client

Direct JSON-RPC 2.0 POST to `https://www.heropedia.org/mcp`. See [heropedia.org/mcp-guide](https://www.heropedia.org/mcp-guide) for examples.

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
