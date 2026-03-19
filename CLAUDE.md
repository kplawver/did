# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

"Did" is a Rails 8.1.2 application using Ruby 4.0.x, PostgreSQL, and the Hotwire stack (Turbo + Stimulus). Asset pipeline uses Propshaft with cssbundling-rails and jsbundling-rails.

## Common Commands

### Development
```bash
bin/setup              # Initial setup (install deps, prepare DB, clear logs)
bin/dev                # Start development server
```

### Testing
```bash
bin/rails test                        # Run all unit/integration tests
bin/rails test test/models/foo_test.rb  # Run a single test file
bin/rails test test/models/foo_test.rb:42  # Run a single test by line number
bin/rails test:system                 # Run system tests (Selenium/Capybara)
```

### Linting & Security
```bash
bin/rubocop              # Lint (rubocop-rails-omakase style)
bin/rubocop -a           # Auto-correct lint issues
bin/brakeman             # Security scan
bin/bundler-audit        # Gem vulnerability audit
```

### Database
```bash
bin/rails db:prepare     # Create + migrate (idempotent)
bin/rails db:migrate     # Run pending migrations
bin/rails db:reset       # Drop, create, migrate, seed
```

### Full CI Suite (Local)
```bash
bin/ci                   # Runs: setup → rubocop → bundler-audit → yarn audit → brakeman → tests → seed check
```

## Architecture

- **Frontend:** Hotwire (Turbo + Stimulus), Propshaft asset pipeline
- **Background jobs:** Solid Queue (database-backed, runs in Puma process)
- **Caching:** Solid Cache (database-backed)
- **WebSockets:** Solid Cable (database-backed)
- **Production multi-database:** Separate databases for primary, cache, queue, and cable

## Code Style

Uses `rubocop-rails-omakase` — the Rails team's opinionated style guide. Run `bin/rubocop` before committing.

## CI (GitHub Actions)

Four jobs run on PRs and pushes to main:
1. **scan_ruby** — Brakeman + bundler-audit
2. **lint** — RuboCop
3. **test** — Rails tests against PostgreSQL service container
4. **system-test** — Selenium system tests (uploads failure screenshots as artifacts)

## Deployment

Dockerized with Kamal support. The Docker entrypoint runs `db:prepare` automatically on startup. DigitalOcean App Platform config lives in `.do/app.yaml`.
