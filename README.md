# Did

A personal journal app built with Rails 8.1 and the Hotwire stack. Track what you did, capture thoughts and ideas, manage todos, and review your days.

## Prerequisites

- [mise](https://mise.jdx.dev/) (or install Ruby 4.0.2 and Node 24 manually - we don't recommend that)
- PostgreSQL - `brew install postgresql` on mac with [Homebrew](https://brew.sh), or get it from [the website](https://www.postgresql.org/)
- [Yarn](https://yarnpkg.com/)

## MCP

See [the MCP README](mcp/README.md)

## Setup

### 1. Install mise

```bash
# macOS
brew install mise

# Or follow https://mise.jdx.dev/getting-started.html
```

Activate mise in your shell (add to `~/.zshrc` or `~/.bashrc`):

```bash
eval "$(mise activate zsh)"  # or bash/fish
```

### 2. Install tool versions

From the project directory:

```bash
mise install
```

This installs Ruby 4.0.2 and Node 24 as defined in `mise.toml`.

### 3. Install dependencies and prepare the database

```bash
bin/setup --skip-server
```

This installs Ruby and JS dependencies, creates the database, and runs migrations.

## Development

Start all processes (Rails server, JS/CSS watchers, MCP server):

```bash
bin/dev
```

The app will be available at `http://localhost:3000`.

## Testing

```bash
bundle exec rspec              # Run all specs
bundle exec rspec spec/models/ # Run model specs only
```

## Linting

```bash
bin/rubocop    # Check style
bin/rubocop -a # Auto-correct
```

## Full CI suite

```bash
bin/ci
```

Runs setup, rubocop, bundler-audit, yarn audit, brakeman, rspec, and a seed check.
