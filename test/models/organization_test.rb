require "test_helper"

class OrganizationTest < ActiveSupport::TestCase
  test "valid organization" do
    org = Organization.new(name: "Test Org", slug: "test-org")
    assert org.valid?
  end

  test "requires name" do
    org = Organization.new(slug: "test-org")
    assert_not org.valid?
    assert_includes org.errors[:name], "can't be blank"
  end

  test "requires slug" do
    org = Organization.new(name: nil, slug: nil)
    assert_not org.valid?
    assert_includes org.errors[:slug], "can't be blank"
  end

  test "slug must be unique" do
    org = Organization.new(name: "Something", slug: organizations(:one).slug)
    assert_not org.valid?
    assert_includes org.errors[:slug], "has already been taken"
  end

  test "slug format must be lowercase alphanumeric with hyphens" do
    org = Organization.new(name: "Test", slug: "Valid-slug-123")
    assert_not org.valid? # uppercase not allowed

    org.slug = "valid-slug-123"
    assert org.valid?

    org.slug = "invalid slug"
    assert_not org.valid?

    org.slug = "invalid_slug"
    assert_not org.valid?
  end

  test "auto-generates slug from name on create" do
    org = Organization.new(name: "My Great Organization")
    org.valid?
    assert_equal "my-great-organization", org.slug
  end

  test "does not overwrite slug if already set" do
    org = Organization.new(name: "My Great Organization", slug: "custom-slug")
    org.valid?
    assert_equal "custom-slug", org.slug
  end

  test "website_url must be valid URL if present" do
    org = organizations(:one)
    org.website_url = "not-a-url"
    assert_not org.valid?
    assert_includes org.errors[:website_url], "must be a valid URL"

    org.website_url = "https://example.com"
    assert org.valid?

    org.website_url = ""
    assert org.valid?

    org.website_url = nil
    assert org.valid?
  end

  test "repo_url must be valid URL if present" do
    org = organizations(:one)
    org.repo_url = "not-a-url"
    assert_not org.valid?
    assert_includes org.errors[:repo_url], "must be a valid URL"

    org.repo_url = "https://github.com/example"
    assert org.valid?

    org.repo_url = ""
    assert org.valid?

    org.repo_url = nil
    assert org.valid?
  end

  test "to_param returns slug" do
    org = organizations(:one)
    assert_equal org.slug, org.to_param
  end

  test "has many memberships" do
    org = organizations(:one)
    assert_respond_to org, :memberships
    assert org.memberships.count > 0
  end

  test "has many users through memberships" do
    org = organizations(:one)
    assert_respond_to org, :users
    assert_includes org.users, users(:one)
  end

  test "rejects logo with invalid content type" do
    org = organizations(:one)
    org.logo.attach(
      io: StringIO.new("fake file content"),
      filename: "malicious.exe",
      content_type: "text/plain"
    )
    assert_not org.valid?
    assert org.errors[:logo].any? { |msg| msg.include?("not a valid file type") || msg.include?("content type") }
  end

  test "rejects logo exceeding 5MB" do
    org = organizations(:one)
    org.logo.attach(
      io: StringIO.new("x" * (6.megabytes)),
      filename: "huge-image.png",
      content_type: "image/png"
    )
    assert_not org.valid?
    assert org.errors[:logo].any? { |msg| msg.include?("size") || msg.include?("too large") || msg.include?("5 MB") }
  end

  test "accepts logo with valid content type and size" do
    org = organizations(:one)
    org.logo.attach(
      io: StringIO.new("GIF89a" + "\x00" * 100),
      filename: "logo.gif",
      content_type: "image/gif"
    )
    assert org.valid?, "Expected organization with valid logo to be valid, but got errors: #{org.errors.full_messages}"
  end

  test "accepts logo with each valid image content type" do
    %w[image/png image/jpeg image/gif image/webp].each do |content_type|
      org = organizations(:one)
      org.logo.attach(
        io: StringIO.new("\x00" * 100),
        filename: "logo.#{content_type.split('/').last}",
        content_type: content_type
      )
      assert org.valid?, "Expected #{content_type} to be accepted but got errors: #{org.errors.full_messages}"
      org.logo.purge
    end
  end
end
