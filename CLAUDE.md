# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

VolunteerBoard is a Rails 8.1 application using Ruby 3.4.8, PostgreSQL, Propshaft (asset pipeline), Importmap (JS), and Hotwire (Turbo + Stimulus). Deployment is configured for Kamal with Docker.

## Common Commands

- **Dev server:** `bin/dev`
- **Setup:** `bin/setup` (install deps, prepare DB, start server) or `bin/setup --skip-server`
- **Full CI locally:** `bin/ci`
- **Tests:** `bin/rails test`
- **Single test file:** `bin/rails test test/models/foo_test.rb`
- **Single test by line:** `bin/rails test test/models/foo_test.rb:42`
- **System tests:** `bin/rails test:system`
- **Lint:** `bin/rubocop` (uses rubocop-rails-omakase)
- **Lint with autofix:** `bin/rubocop -a`
- **Security scans:** `bin/brakeman --no-pager` and `bin/bundler-audit`
- **JS dependency audit:** `bin/importmap audit`
- **DB prepare:** `bin/rails db:prepare`
- **DB reset:** `bin/setup --reset`

## Architecture

- **Database:** PostgreSQL for all environments. Production uses `DATABASE_URL` with optional separate databases for cache (Solid Cache), queue (Solid Queue), and cable (Solid Cable).
- **Asset pipeline:** Propshaft (not Sprockets). JS via importmap-rails (no Node/npm/yarn).
- **Frontend:** Hotwire stack — Turbo for navigation/frames/streams, Stimulus for JS behavior.
- **Testing:** Minitest with fixtures. Tests run in parallel. System tests use Capybara + Selenium.
- **Linting:** rubocop-rails-omakase style guide. Config in `.rubocop.yml`.
