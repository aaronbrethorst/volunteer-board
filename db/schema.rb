# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_03_09_180956) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "action_text_rich_texts", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "interests", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "listing_id", null: false
    t.text "message"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["listing_id"], name: "index_interests_on_listing_id"
    t.index ["user_id", "listing_id"], name: "index_interests_on_user_id_and_listing_id", unique: true
    t.index ["user_id"], name: "index_interests_on_user_id"
  end

  create_table "listings", force: :cascade do |t|
    t.string "commitment"
    t.datetime "created_at", null: false
    t.datetime "discarded_at"
    t.integer "discipline", null: false
    t.string "location", default: "Remote"
    t.integer "organization_id", null: false
    t.string "skills"
    t.integer "status", default: 0, null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["discarded_at"], name: "index_listings_on_discarded_at"
    t.index ["organization_id", "status"], name: "index_listings_on_organization_id_and_status"
    t.index ["organization_id"], name: "index_listings_on_organization_id"
  end

  create_table "memberships", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "organization_id", null: false
    t.integer "role", default: 1, null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["organization_id"], name: "index_memberships_on_organization_id"
    t.index ["user_id", "organization_id"], name: "index_memberships_on_user_id_and_organization_id", unique: true
    t.index ["user_id"], name: "index_memberships_on_user_id"
  end

  create_table "organizations", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.datetime "discarded_at"
    t.string "name", null: false
    t.string "repo_url"
    t.string "slug", null: false
    t.datetime "updated_at", null: false
    t.string "website_url"
    t.index ["discarded_at"], name: "index_organizations_on_discarded_at"
    t.index ["slug"], name: "index_organizations_on_slug", unique: true
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.text "bio"
    t.datetime "created_at", null: false
    t.string "email_address", null: false
    t.string "github_uid"
    t.string "github_username"
    t.string "linkedin_uid"
    t.string "linkedin_username"
    t.string "name", null: false
    t.string "password_digest", null: false
    t.string "portfolio_url"
    t.boolean "site_admin", default: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
    t.index ["github_uid"], name: "index_users_on_github_uid", unique: true, where: "(github_uid IS NOT NULL)"
    t.index ["linkedin_uid"], name: "index_users_on_linkedin_uid", unique: true, where: "(linkedin_uid IS NOT NULL)"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "interests", "listings"
  add_foreign_key "interests", "users"
  add_foreign_key "listings", "organizations"
  add_foreign_key "memberships", "organizations"
  add_foreign_key "memberships", "users"
  add_foreign_key "sessions", "users"
end
