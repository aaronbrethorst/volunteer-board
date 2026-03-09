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
- **Coverage analysis:** `bundle exec cov-loupe totals` or `bundle exec cov-loupe list` (requires running tests first)

## Architecture

- **Database:** PostgreSQL for all environments. Production uses `DATABASE_URL` with optional separate databases for cache (Solid Cache), queue (Solid Queue), and cable (Solid Cable).
- **Asset pipeline:** Propshaft (not Sprockets). JS via importmap-rails (no Node/npm/yarn).
- **Frontend:** Hotwire stack — Turbo for navigation/frames/streams, Stimulus for JS behavior. Tailwind CSS for styling.
- **Testing:** Minitest with fixtures. Tests run in parallel. System tests use Capybara + Selenium. SimpleCov for coverage with cov-loupe MCP for analysis.
- **Linting:** rubocop-rails-omakase style guide. Config in `.rubocop.yml`.

## Authentication & Authorization

Authentication uses a custom concern (`Authentication` in `app/controllers/concerns/authentication.rb`) with database-backed sessions and signed cookies. `Current` (ActiveSupport::CurrentAttributes) holds the session and delegates `:user`.

- All controllers require authentication by default via `before_action :require_authentication`.
- Public pages opt out with `allow_unauthenticated_access only: [:index, :show]`.
- `authenticated?` helper is available in controllers and views.
- Admin access: `Current.user&.site_admin?`, enforced in `Admin::BaseController`.
- Org membership checks: `organization.memberships.exists?(user: Current.user)`.
- Owner checks: `organization.memberships.exists?(user: Current.user, role: :owner)`.
- OAuth providers (GitHub, LinkedIn) handled via OmniAuth in `OmniauthCallbacksController`.

## Key Model Patterns

- **Soft-delete:** `Discardable` concern (`app/models/concerns/discardable.rb`) adds `discarded_at` timestamp with `discard`/`undiscard`/`kept?`/`discarded?` methods and `kept`/`discarded` scopes. Used by Organization and Listing. Controllers use `.kept` to exclude soft-deleted records.
- **Slug routing:** Organizations use `param: :slug` in routes and `to_param` returning slug. Look up with `find_by!(slug:)`.
- **Polymorphic flagging:** Flag model uses `belongs_to :flaggable, polymorphic: true` for both Organizations and Listings. The controller resolves the flaggable from route params (not user-controlled type strings).
- **Enums:** Listing has `discipline` and `status` enums; Membership has `role` enum; Flag has `status` enum. All use integer-backed values.

## View & Component Patterns

- **Layouts:** `application.html.erb` (global nav, flash, footer) and `admin.html.erb` (sidebar + application layout). Admin layout uses `content_for(:main_content)`.
- **ViewComponent:** Form field components in `app/components/form/` (text_field, email_field, password_field, url_field, text_area, select, file_field, submit_button). `ListingCardComponent` for listing cards.
- **Pagination:** Pagy gem. Pattern: `@pagy, @records = pagy(collection)`. Render with `@pagy.series_nav`.

## Admin Section

All admin controllers inherit from `Admin::BaseController` which enforces `site_admin?`. The admin dashboard at `admin/dashboard#show` displays aggregate counts. Admin can discard/restore organizations and listings, resolve flags, and view users.

## Test Conventions

- **Fixtures** in `test/fixtures/` — users(:one) is site_admin, users(:two) is regular. Organizations and listings include discarded variants.
- **`sign_in_as(user)`** helper in `test/test_helpers/session_test_helper.rb` for controller tests.
- **`count_queries(&block)`** helper in `test/test_helpers/query_counter_helper.rb` for N+1 detection.
- Tests are integration tests (`ActionDispatch::IntegrationTest`) for controllers, not functional tests.
