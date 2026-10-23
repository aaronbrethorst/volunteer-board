require "test_helper"

class SeedsTest < ActiveSupport::TestCase
  setup do
    @original_env = ENV.to_h.slice("ADMIN_EMAIL", "ADMIN_PASSWORD")
    @original_rails_env = Rails.env
  end

  teardown do
    ENV.delete("ADMIN_EMAIL")
    ENV.delete("ADMIN_PASSWORD")
    @original_env.each { |key, value| ENV[key] = value }
    Rails.env = @original_rails_env
  end

  test "creates a confirmed site admin from the environment" do
    ENV["ADMIN_EMAIL"] = "boss@example.com"
    ENV["ADMIN_PASSWORD"] = "correct-horse-battery"

    capture_io { load_seeds }

    admin = User.find_by!(email_address: "boss@example.com")
    assert admin.site_admin?
    assert admin.email_confirmed?
    assert admin.authenticate("correct-horse-battery")
  end

  test "re-seeding does not reset an existing admin's password" do
    ENV["ADMIN_EMAIL"] = "boss@example.com"
    ENV["ADMIN_PASSWORD"] = "first-password-123"
    capture_io { load_seeds }

    ENV["ADMIN_PASSWORD"] = "second-password-456"
    capture_io { load_seeds }

    admin = User.find_by!(email_address: "boss@example.com")
    assert admin.authenticate("first-password-123")
    assert_not admin.authenticate("second-password-456")
  end

  test "production never prints the admin password" do
    Rails.env = "production"
    ENV["ADMIN_EMAIL"] = "boss@example.com"
    ENV["ADMIN_PASSWORD"] = "super-secret-password"

    out, _err = capture_io { load_seeds }

    assert_includes out, "boss@example.com"
    assert_not_includes out, "super-secret-password"
  end

  test "production without credentials creates no admin" do
    Rails.env = "production"

    assert_no_difference "User.count" do
      capture_io { load_seeds }
    end
  end

  test "development defaults to a non-routable example.com address" do
    capture_io { load_seeds }

    admin = User.find_by!(email_address: "admin@example.com")
    assert admin.site_admin?
    assert admin.email_confirmed?
  end

  private

  def load_seeds
    load Rails.root.join("db/seeds.rb")
  end
end
