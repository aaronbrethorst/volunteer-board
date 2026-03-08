# VolunteerBoard — MVP Feature Spec

## Problem

Laid-off tech workers want to contribute their skills to open-source and volunteer software projects, but the current experience is fragmented: you have to find a repo, clone it, and figure things out on your own. There's no central place that treats volunteer positions the way a job board treats paid roles — with context about the project, the team, the commitment, and what skills are actually needed.

This isn't just for engineers. UX designers, product managers, biz dev folks, sales professionals, and other disciplines all have expertise that OSS and volunteer projects desperately need but rarely recruit for.

## User Roles

### 1. Volunteer (Job Seeker)
A tech professional looking for volunteer opportunities. Can browse listings, express interest, and manage their profile.

### 2. Organization Admin
Represents a project or organization posting volunteer positions. Can create an org profile, post listings, and review interested volunteers.

### 3. Site Admin
Manages the platform. Can moderate content, manage users, and oversee the system.

## MVP Features

### Critical — Must Ship

#### Authentication & Accounts
- Sign up / sign in / sign out (Rails 8 built-in `has_authentication`)
- Email and password based auth
- User profile with name, bio, links (GitHub, LinkedIn, portfolio)
- Role selection during signup: Volunteer or Organization Admin

#### Organizations
- Create and edit an organization profile (name, description, website, logo, repo URL)
- An organization belongs to the user who created it
- Public org profile page listing all active positions

#### Listings (Volunteer Positions)
- CRUD for listings, scoped to the org admin who owns the organization
- Fields:
  - **Title** (e.g. "UX Researcher", "Rails Backend Developer", "Technical Writer")
  - **Discipline/Category** (Engineering, UX/Design, Product, Marketing, Biz Dev, Sales, DevOps, Documentation, Community, Other)
  - **Description** (rich text via Action Text)
  - **Commitment level** (e.g. "~5 hrs/week", "One-time project", "Flexible")
  - **Remote/Location** (most will be remote, but allow specifying)
  - **Skills needed** (free-form tags)
  - **Status** (Open / Filled / Closed)
  - **Organization** (belongs_to)
- Public listing detail page showing all of the above plus org info

#### Browsing & Discovery
- Homepage showing recent open listings
- Filter by discipline/category
- Simple text search (listing title, description, org name)
- Paginated results

#### Expressing Interest
- Logged-in volunteers can click "I'm Interested" on a listing
- Org admin sees a list of interested volunteers (with links to their profiles) on each listing
- Volunteer sees a list of listings they've expressed interest in on their dashboard

#### Basic Admin
- Site admin role (seeded or set via console)
- Admin can soft-delete listings or organizations that violate guidelines

---

### Nice to Have — Post-MVP

These are explicitly **out of scope** for initial launch to keep time-to-market short:

- **Messaging / chat** between volunteers and org admins (use email links for now)
- **Application flow** with cover letter / resume upload (interest expression is enough for MVP)
- **Skills matching / recommendations** (algorithmic matching)
- **Reviews / endorsements** (reputation system)
- **OAuth** (GitHub, Google login)
- **Email notifications** (transactional emails for interest, status changes)
- **Org team members** (multiple admins per org)
- **Saved searches / bookmarks**
- **RSS/Atom feeds** for new listings
- **API** (JSON endpoints for integrations)

## Data Model (Core)

```
User
  - email_address :string (unique, required)
  - password_digest :string
  - name :string
  - bio :text
  - github_url :string
  - linkedin_url :string
  - portfolio_url :string
  - role :integer (enum: volunteer, org_admin, site_admin)
  - has_many :organizations
  - has_many :interests
  - has_many :interested_listings, through: :interests, source: :listing

Organization
  - name :string (required)
  - description :text
  - website_url :string
  - repo_url :string
  - logo (Active Storage attachment)
  - belongs_to :user (the admin/creator)
  - has_many :listings

Listing
  - title :string (required)
  - discipline :integer (enum)
  - commitment :string
  - location :string (default: "Remote")
  - skills :string (comma-separated tags for MVP; normalize later)
  - status :integer (enum: open, filled, closed; default: open)
  - has_rich_text :description (Action Text)
  - belongs_to :organization
  - has_many :interests
  - has_many :interested_volunteers, through: :interests, source: :user

Interest
  - belongs_to :user
  - belongs_to :listing
  - unique constraint on [user_id, listing_id]
  - timestamps (so org admin can see when interest was expressed)
```

## Key Technical Decisions

| Decision | Choice | Rationale |
|---|---|---|
| Auth | `has_authentication` (Rails 8) | Built-in, no gem needed |
| Rich text | Action Text | Ships with Rails, handles descriptions well |
| File uploads | Active Storage (local disk for dev, S3 for prod) | Ships with Rails |
| Search | `WHERE ... LIKE` with SQLite | Good enough for MVP; swap to pg_search or Meilisearch later |
| Pagination | Pagy or `will_paginate` | Lightweight, well-supported |
| CSS | Tailwind CSS or Pico CSS via CDN | Fast to style without a build step |
| JS | Turbo + Stimulus (Hotwire) | Already configured in Rails 8 |
| Authorization | Simple `before_action` checks | No Pundit/CanCanCan needed for 3 roles |

## Page Map

| Page | Route | Access |
|---|---|---|
| Homepage / listing index | `GET /` | Public |
| Listing detail | `GET /listings/:id` | Public |
| Sign up | `GET /signup` | Public |
| Sign in | `GET /signin` | Public |
| Volunteer dashboard | `GET /dashboard` | Volunteer |
| Org admin dashboard | `GET /dashboard` | Org Admin |
| New organization | `GET /organizations/new` | Org Admin |
| Org profile | `GET /organizations/:id` | Public |
| New listing | `GET /organizations/:org_id/listings/new` | Org Admin (owner) |
| Edit listing | `GET /listings/:id/edit` | Org Admin (owner) |
| Interested volunteers | `GET /listings/:id/interests` | Org Admin (owner) |
| Admin panel | `GET /admin` | Site Admin |

## Success Metrics (Post-Launch)

- Number of organizations registered
- Number of listings posted
- Number of interest expressions per listing
- Volunteer-to-listing ratio by discipline
- Return visitor rate
