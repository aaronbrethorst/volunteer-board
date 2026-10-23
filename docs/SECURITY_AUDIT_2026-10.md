# Security Audit — VolunteerBoard (OSSVolunteers)

**Date:** 2026-10-23
**Branch:** `upgrade-ruby-rails-gems` (Ruby 4.0.6, Rails 8.1.4, all gems at latest resolvable versions)
**Scope:** All application code (`app/`, `config/`, `db/seeds.rb`, `bin/docker-entrypoint`, Kamal config), dependency scans, and dynamic probing via throwaway integration tests.

## Summary

| Tool | Result |
|---|---|
| `bin/brakeman` (8.1.0) | 0 warnings |
| `bin/bundler-audit` (advisory DB updated 2026-10-21) | No vulnerabilities |
| `bin/importmap audit` | No vulnerable packages |
| `bin/importmap outdated` | Nothing outdated |
| `bin/rubocop` | No offenses |
| `bin/rails test` | 425 runs, 0 failures, 0 errors |

The codebase is in good shape overall: strong params everywhere, no raw SQL interpolation of user input, no `html_safe`/`raw` on user data, URL attributes are scheme-validated, OAuth won't auto-link to an existing account by email, rate limits exist on every credential endpoint, and CSRF/host authorization/`force_ssl` are configured. The issues below are logic/authorization and configuration findings that scanners can't catch.

| # | Severity | Finding |
|---|---|---|
| 1 | **High** (conditional) | Seeded site-admin uses an email at a domain that may not be controlled, and the account is unconfirmed |
| 2 | **Medium** | Discarding an organization does not hide or lock its listings |
| 3 | **Medium** | Sentry `send_default_pii = true` ships session cookies to a third party |
| 4 | **Medium** | Seeded admin password is printed to production logs |
| 5 | Low–Medium | CSP nonce is the session ID (static per session; empty when no session) |
| 6 | Low | Inconsistent authorization between interests `index` (owners) and `show` (any member) |
| 7 | Low | Unconfirmed accounts can express interest; their unverified email becomes the `Reply-To` |
| 8 | Low | Interests can be created on filled/closed listings |
| 9 | Low | OAuth failure `message` param is reflected into the flash |
| 10 | Low | No server-side session expiry or "sign out everywhere" |
| 11 | Info | Active Storage direct-upload endpoint is open to unauthenticated users |
| 12 | Info | Hash-typed `query` param causes a 500 |
| 13 | Info | Remaining outdated gems are pinned by other gems |

---

## Findings

### 1. Seeded site-admin email domain / unconfirmed admin — High (conditional)

`db/seeds.rb` creates `admin@volunteerboard.org` with `site_admin: true` and **no `email_confirmed_at`**. The app is served from `ossvolunteers.com`.

Whoever can receive mail at `volunteerboard.org` can take over the site admin:

1. `POST /passwords` with `admin@volunteerboard.org` → because the email is unconfirmed, `PasswordsController#create` sends a confirmation email.
2. Click the confirmation link → account is now confirmed.
3. `POST /passwords` again → a reset link is sent → set a new password → full admin, including Mission Control Jobs.

If the project does not own `volunteerboard.org` (or lets it lapse), this is a full admin takeover by anyone who registers the domain.

**Fix:** Seed the admin from an env var on a domain you control (e.g. `ENV.fetch("ADMIN_EMAIL")`), set `email_confirmed_at: Time.current` in the seed, and confirm the production admin's email address today.

### 2. Discarded organizations' listings stay live — Medium

`Listing.available` is `where(status: :open).kept` and `ListingsController#set_listing` / `InterestsController#set_listing` / `FlagsController` use `Listing.kept` — none check `organization.discarded_at`. Verified with a probe test: after an admin discards an org, its open listings still appear on `/` and `/listings`, `GET /listings/:id` returns 200, and members can still edit them and volunteers can still submit interest (sending email to the discarded org's owners).

This defeats the admin moderation feature — discarding a spam/abusive org leaves all its content public.

**Fix:** join and filter on the organization, e.g.

```ruby
# Listing
scope :kept, -> { where(discarded_at: nil).joins(:organization).merge(Organization.kept) }
```

(or a separate `visible` scope used by all public-facing controllers), plus tests for each entry point.

### 3. Sentry sends session cookies — Medium

`config/initializers/sentry.rb` sets `send_default_pii = true`. With this on, Sentry attaches request cookies, headers, and IPs to events. The `session_id` signed cookie is a bearer credential: anyone with access to the Sentry project (or a Sentry-side breach) can replay it and become that user — including admins — for up to two weeks.

**Fix:** set `send_default_pii = false`, or keep it but strip cookies/authorization headers in `before_send`:

```ruby
config.before_send = ->(event, _hint) {
  event.request&.cookies = {}
  event.request&.headers&.delete("Cookie")
  event
}
```

### 4. Admin password logged on first deploy — Medium

`bin/docker-entrypoint` runs `db:prepare`, which seeds on database creation. The seed `puts`es the generated admin password, so it lands in the production log stream (Render/Kamal logs, any log forwarding). Also, re-running `db:seed` silently resets the admin password.

**Fix:** don't print the password; require `ADMIN_PASSWORD` in production (`ENV.fetch("ADMIN_PASSWORD")` with no default when `Rails.env.production?`), and use `find_or_create_by!` so re-seeding doesn't reset an existing admin.

### 5. CSP nonce derived from session ID — Low–Medium

`config.content_security_policy_nonce_generator = ->(request) { request.session.id.to_s }`.

- The nonce is identical for every page in a session, so a nonce leaked from any page (cache, HTML-injection, Referer to a third party) works on all pages for that session.
- Probe tests showed the header as `script-src 'self' 'nonce-'` and `nonce=""` in the HTML when no session exists yet (test env). In production `csrf_meta_tags` usually forces a session, but an empty nonce is an invalid source and would block the inline importmap.

**Fix:** use the current Rails default, `->(request) { SecureRandom.base64(16) }`. Turbo reads the nonce from the `csp-nonce` meta tag, which `_head.html.erb` already emits via `csp_meta_tag`.

### 6. Interests: `index` is owner-only, `show` is any member — Low

`InterestsController#index` requires `role: :owner`, but `#show` only requires any membership. A plain `member` can't list volunteers but can enumerate `/listings/:id/interests/:interest_id` and see each volunteer's email, bio, and portfolio. Decide on one rule; if volunteers were told their info goes to "the organization", tightening `show` to owners matches `index` and the email notification recipients.

### 7. Unconfirmed users can submit interest — Low

There's no `email_confirmed?` check on interest creation (or org creation). The interest mailer sets `reply_to: @interest.user.email_address`, so someone can register with a victim's address (unconfirmed) and cause owners to email the victim. Require a confirmed email for `InterestsController#create` (and consider for `OrganizationsController#create`).

### 8. Interest accepted on filled/closed listings — Low

`InterestsController` loads `Listing.kept`, not `Listing.available`; verified that `POST /listings/:filled_id/interest` succeeds and notifies owners. Use `available` for `new`/`create`.

### 9. Reflected OAuth failure message — Low

`OmniauthCallbacksController#failure` renders `params[:message]` into the flash. It's HTML-escaped (no XSS), but a crafted link like `/auth/failure?message=Your+account+is+locked,+call+555-0100` displays attacker-chosen text on your domain (verified). Map known OmniAuth error keys to fixed strings and fall back to a generic message.

### 10. No server-side session expiry — Low

`Session` rows never expire; only the cookie carries a 2-week expiry. There's no UI to see or revoke other sessions (password reset does destroy them — good). Consider rejecting sessions older than N days in `find_session_by_cookie`, a periodic cleanup job, and calling `reset_session` in `start_new_session_for` to rotate the Rails session on login.

### 11. Open direct uploads — Info

Active Storage's `POST /rails/active_storage/direct_uploads` is reachable without authentication (Rails default; Trix/Action Text uses it). Anyone can create blobs and get signed upload URLs into the R2 bucket, which is a storage-abuse vector. If not needed for anonymous users, subclass `ActiveStorage::DirectUploadsController` to require authentication.

### 12. 500 on hash-typed `query` — Info

`HomepageController` and `ListingsController#index` call `sanitize_sql_like(params[:query])`; `?query[a]=b` passes a Hash and raises (500). Not exploitable, just noisy in Sentry. Use `params[:query].to_s` or `params.permit(:query, :discipline)`.

### 13. Dependencies that can't reach latest — Info

All direct gems are on their latest versions. Four transitive gems are held back by their dependents (none have known advisories):

| Gem | Locked | Latest | Held by |
|---|---|---|---|
| marcel | 1.2.1 | 2.1.0 | activestorage 8.1.4 (`~> 1.0`) |
| prism | 1.9.0 | 2.0.0 | minitest 6.0.6 (`~> 1.5`) |
| amazing_print | 2.0.0 | 3.0.0 | cov-loupe 6.1.0 (`~> 2.0`) |
| net-ssh | 7.3.6 | 8.0.2 | kamal toolchain |

---

## Things checked and found OK

- **SQL injection:** all `where` clauses parameterized; `ILIKE` input escaped with `sanitize_sql_like`; the subquery in `OrganizationsController#index` is built from internal scopes only.
- **XSS:** no `raw`/`html_safe` on user data (only Sentry's trace meta tag); Action Text sanitizes rich text; `website_url`/`repo_url`/`portfolio_url` are restricted to `http(s)` both at validation and render time (`safe_external_url`).
- **Mass assignment:** all controllers use `permit`/`expect` with explicit allowlists; `site_admin`, `email_confirmed_at`, OAuth UIDs aren't assignable.
- **AuthN:** `authenticate_by` (timing-safe), bcrypt, 8-char minimum, rate-limited login/registration/reset/confirmation/OAuth, password-reset tokens expire and revoke all sessions, confirmation tokens are single-use (fingerprinted on `email_confirmed_at`), session cookie is signed + `httponly` + `secure` + `SameSite=Lax`.
- **OAuth:** POST-only request phase with `omniauth-rails_csrf_protection`; an OAuth login whose email matches an existing account is refused rather than auto-linked; linking a provider already tied to another user is refused; unlink is restricted to an allowlist.
- **AuthZ:** org edit is owner-only; listing create/edit membership-checked; admin controllers and Mission Control Jobs inherit `require_admin`; flags resolve the flaggable from route params, not a user-supplied type.
- **Uploads:** logo type is sniffed by Marcel and restricted to PNG/JPEG/GIF/WEBP (no SVG), 5 MB cap.
- **Config:** `force_ssl`, host authorization with anchored patterns, sensitive params filtered from logs, `attributes_for_inspect = [:id]`, credentials encrypted with no master key committed, Kamal DB port bound to `127.0.0.1`.
