# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

"Did" is a Rails 8.1.2 application using Ruby 4.0.2, Dolt (MySQL-compatible, trilogy adapter), and the Hotwire stack (Turbo + Stimulus). Asset pipeline uses Propshaft with cssbundling-rails (Tailwind + DaisyUI) and jsbundling-rails (esbuild).

## Common Commands

### Development
```bash
bin/setup              # Initial setup (install deps, prepare DB, clear logs)
bin/dev                # Start development server (foreman: Rails + CSS + JS watchers)
yarn build             # One-off build of CSS + JS assets
```

### Testing
```bash
bundle exec rspec                          # Run all specs
bundle exec rspec spec/models/             # Run model specs
bundle exec rspec spec/requests/           # Run request specs
bundle exec rspec spec/models/user_spec.rb # Run a single spec file
bundle exec rspec spec/models/user_spec.rb:10  # Run a single example by line
```

### Linting & Security
```bash
bin/rubocop              # Lint (rubocop-rails-omakase style)
bin/rubocop -a           # Auto-correct lint issues
bin/brakeman             # Security scan
bin/bundler-audit        # Gem vulnerability audit
```

### Database (Dolt)
```bash
dolt sql-server          # Start Dolt SQL server (must be running for Rails)
bin/rails db:prepare     # Create + migrate (idempotent)
bin/rails db:migrate     # Run pending migrations
bin/rails db:reset       # Drop, create, migrate, seed
```

### Full CI Suite (Local)
```bash
bin/ci                   # Runs: setup → rubocop → bundler-audit → yarn audit → brakeman → rspec → seed check
```

## Architecture

- **Frontend:** Hotwire (Turbo + Stimulus), Propshaft asset pipeline, Tailwind CSS + DaisyUI
- **JS bundling:** esbuild via jsbundling-rails
- **CSS bundling:** Tailwind CLI via cssbundling-rails
- **Authentication:** Devise (email/password) + WebAuthn passkeys
- **Background jobs:** Solid Queue (database-backed, runs in Puma process)
- **Caching:** Solid Cache (database-backed)
- **WebSockets:** Solid Cable (database-backed)
- **Testing:** RSpec, FactoryBot, Shoulda Matchers, Faker
- **Production multi-database:** Separate databases for primary, cache, queue, and cable

## Authentication

- Devise with `:database_authenticatable`, `:registerable`, `:recoverable`, `:rememberable`, `:validatable`, `:lockable`, `:trackable`
- No `:confirmable` — users can sign in immediately after registration
- Account locks after 10 failed attempts, unlocks via email or after 1 hour
- Passkey support via `webauthn` gem — users can register/manage passkeys from profile
- Environment variables for production: `WEBAUTHN_ORIGIN`, `WEBAUTHN_RP_ID`

## Code Style

Uses `rubocop-rails-omakase` — the Rails team's opinionated style guide. Run `bin/rubocop` before committing.

## CI (GitHub Actions)

Four jobs run on PRs and pushes to main:
1. **scan_ruby** — Brakeman + bundler-audit
2. **lint** — RuboCop
3. **test** — RSpec (non-system) against MySQL service container
4. **system-test** — RSpec system specs (uploads failure screenshots as artifacts)

## Deployment

Dockerized with Kamal support. The Docker entrypoint runs `db:prepare` automatically on startup. DigitalOcean App Platform config lives in `.do/app.yaml`.
