require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "valid user with all required fields" do
    user = User.new(
      email_address: "new@example.com",
      password: "password123",
      password_confirmation: "password123",
      name: "Test User"
    )
    assert user.valid?
  end

  test "requires name" do
    user = User.new(
      email_address: "new@example.com",
      password: "password123",
      password_confirmation: "password123",
      name: ""
    )
    assert_not user.valid?
    assert_includes user.errors[:name], "can't be blank"
  end

  test "requires unique email_address" do
    existing = users(:one)
    user = User.new(
      email_address: existing.email_address,
      password: "password123",
      password_confirmation: "password123",
      name: "Another User"
    )
    assert_not user.valid?
    assert_includes user.errors[:email_address], "has already been taken"
  end

  test "normalizes email_address" do
    user = User.new(email_address: "  TEST@Example.COM  ", name: "Test", password: "password123")
    assert_equal "test@example.com", user.email_address
  end

  test "rejects invalid email format" do
    user = User.new(
      email_address: "not-an-email",
      password: "password123",
      password_confirmation: "password123",
      name: "Test User"
    )
    assert_not user.valid?
    assert_includes user.errors[:email_address], "is invalid"
  end

  test "requires minimum password length of 8 characters" do
    user = User.new(
      email_address: "short@example.com",
      password: "short",
      password_confirmation: "short",
      name: "Test User"
    )
    assert_not user.valid?
    assert_includes user.errors[:password], "is too short (minimum is 8 characters)"
  end

  test "rejects javascript: portfolio_url" do
    user = users(:one)
    user.portfolio_url = "javascript:alert(document.cookie)"
    assert_not user.valid?
    assert_includes user.errors[:portfolio_url], "must be a valid URL"
  end

  test "rejects data: portfolio_url" do
    user = users(:one)
    user.portfolio_url = "data:text/html,<script>alert(1)</script>"
    assert_not user.valid?
    assert_includes user.errors[:portfolio_url], "must be a valid URL"
  end

  test "accepts https portfolio_url" do
    user = users(:one)
    user.portfolio_url = "https://example.com/portfolio"
    assert user.valid?
  end

  test "accepts blank portfolio_url" do
    user = users(:one)
    user.portfolio_url = ""
    assert user.valid?
  end

  test "rejects portfolio_url with trailing newline injection" do
    user = users(:one)
    user.portfolio_url = "https://example.com\njavascript:alert(1)"
    assert_not user.valid?
    assert_includes user.errors[:portfolio_url], "must be a valid URL"
  end

  test "site_admin defaults to false" do
    user = User.new(
      email_address: "admin@example.com",
      password: "password123",
      name: "Admin"
    )
    assert_equal false, user.site_admin
  end
end
