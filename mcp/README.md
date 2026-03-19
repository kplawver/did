# Did MCP Server

Connect your Did journal to Claude (Desktop, Code, or claude.ai) via the Model Context Protocol.

## Setup

### 1. Generate an API Token

Go to **Edit Profile** → **API Token** → **Generate API Token**

### 2. Start the MCP Server

```bash
bin/mcp          # Starts on port 62770
bin/mcp 3001     # Custom port
```

The MCP server runs as a standalone process alongside your Rails app.

### 3. Connect Claude Desktop

Edit `~/Library/Application Support/Claude/claude_desktop_config.json`:

```json
{
  "mcpServers": {
    "did": {
      "type": "http",
      "url": "http://localhost:62770/",
      "headers": {
        "Authorization": "Bearer YOUR_TOKEN_HERE"
      }
    }
  }
}
```

### 4. Connect Claude Code

```bash
claude mcp add --transport http did http://localhost:62770/ \
  --header "Authorization: Bearer YOUR_TOKEN_HERE"
```

### 5. Production

Replace `localhost:62770` with your production MCP server URL.

## Available Tools

| Tool | Description |
|------|-------------|
| `get_journal_day` | Get a full day's journal (todos + entries) |
| `get_todos` | Get todo items with filtering by date/status |
| `get_entries` | Get journal entries with filtering by date range/tag |
| `search_entries` | Search entry bodies by keyword |

## JSON API

The same token works with the JSON API:

```bash
# Get today's journal
curl -H "Authorization: Bearer TOKEN" http://localhost:3000/api/journal/2026-03-19

# Get todos
curl -H "Authorization: Bearer TOKEN" http://localhost:3000/api/todos?status=incomplete

# Get entries
curl -H "Authorization: Bearer TOKEN" http://localhost:3000/api/entries?tag=did

# Search entries
curl -H "Authorization: Bearer TOKEN" http://localhost:3000/api/entries/search?q=projectx
```
