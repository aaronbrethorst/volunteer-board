require "test_helper"

class OrganizationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @other_user = users(:two)
    @organization = organizations(:one)
  end

  # --- Index ---

  test "index only shows kept organizations" do
    get organizations_path
    assert_response :success
    assert_match organizations(:one).name, response.body
    assert_no_match organizations(:discarded_org).name, response.body
  end

  test "index paginates organizations" do
    25.times do |i|
      Organization.create!(name: "Paginated Org #{i}", slug: "paginated-org-#{i}")
    end

    get organizations_path
    assert_response :success
    assert_select "nav[aria-label]"
  end

  # --- Public profile page ---

  test "show returns 404 for discarded org" do
    get organization_path(organizations(:discarded_org).slug)
    assert_response :not_found
  end

  test "show displays public org profile" do
    get organization_path(@organization.slug)
    assert_response :success
    assert_select "h1", @organization.name
  end

  test "show displays org description" do
    get organization_path(@organization.slug)
    assert_response :success
    assert_match @organization.description, response.body
  end

  test "show displays website and repo links when present" do
    get organization_path(@organization.slug)
    assert_response :success
    assert_select "a[href='#{@organization.website_url}']"
    assert_select "a[href='#{@organization.repo_url}']"
  end

  test "show returns 404 for nonexistent slug" do
    get "/organizations/nonexistent-slug"
    assert_response :not_found
  end

  # --- New / Create ---

  test "new requires authentication" do
    get new_organization_path
    assert_redirected_to new_session_path
  end

  test "new renders form when authenticated" do
    sign_in_as(@user)
    get new_organization_path
    assert_response :success
    assert_select "form" do
      assert_select "input[name='organization[name]']"
      assert_select "textarea[name='organization[description]']"
      assert_select "input[name='organization[website_url]']"
      assert_select "input[name='organization[repo_url]']"
      assert_select "input[name='organization[logo]']"
      assert_select "input[type=submit]"
    end
  end

  test "create requires authentication" do
    post organizations_path, params: { organization: { name: "New Org" } }
    assert_redirected_to new_session_path
  end

  test "create creates organization and owner membership" do
    sign_in_as(@user)
    assert_difference [ "Organization.count", "Membership.count" ], 1 do
      post organizations_path, params: { organization: { name: "Brand New Org", description: "A new org" } }
    end

    org = Organization.find_by(slug: "brand-new-org")
    assert_not_nil org
    assert_redirected_to organization_path(org.slug)

    membership = org.memberships.find_by(user: @user)
    assert_not_nil membership
    assert membership.owner?
  end

  test "create rolls back organization if membership creation fails" do
    sign_in_as(@user)

    # Temporarily make all membership saves fail
    Membership.class_eval { validate :always_fail; def always_fail = errors.add(:base, "forced failure") }

    assert_no_difference [ "Organization.count", "Membership.count" ] do
      post organizations_path, params: { organization: { name: "Doomed Org", description: "Should not persist" } }
    end
    assert_response :unprocessable_entity
  ensure
    # Remove the temporary validation
    Membership._validators.delete(:always_fail)
    Membership._validate_callbacks.each do |cb|
      if cb.filter == :always_fail
        Membership._validate_callbacks.delete(cb)
        break
      end
    end
    Membership.remove_method(:always_fail) if Membership.method_defined?(:always_fail)
  end

  test "create renders new on validation failure" do
    sign_in_as(@user)
    assert_no_difference "Organization.count" do
      post organizations_path, params: { organization: { name: "" } }
    end
    assert_response :unprocessable_entity
  end

  # --- Edit / Update ---

  test "edit requires authentication" do
    get edit_organization_path(@organization.slug)
    assert_redirected_to new_session_path
  end

  test "edit is accessible to org owner" do
    sign_in_as(@user) # user one is owner of org one
    get edit_organization_path(@organization.slug)
    assert_response :success
    assert_select "form"
  end

  test "edit redirects non-owner member" do
    sign_in_as(@other_user) # user two is member (not owner) of org one
    get edit_organization_path(@organization.slug)
    assert_redirected_to organization_path(@organization.slug)
  end

  test "edit redirects user with no membership" do
    # Create a user with no membership to org one
    non_member = User.create!(name: "Non Member", email_address: "nonmember@example.com", password: "password123")
    sign_in_as(non_member)
    get edit_organization_path(@organization.slug)
    assert_redirected_to organization_path(@organization.slug)
  end

  test "update requires authentication" do
    patch organization_path(@organization.slug), params: { organization: { name: "Updated" } }
    assert_redirected_to new_session_path
  end

  test "update succeeds for org owner" do
    sign_in_as(@user)
    patch organization_path(@organization.slug), params: { organization: { name: "Updated Name" } }
    assert_redirected_to organization_path(@organization.slug)
    @organization.reload
    assert_equal "Updated Name", @organization.name
  end

  test "update rejects non-owner" do
    sign_in_as(@other_user)
    patch organization_path(@organization.slug), params: { organization: { name: "Hacked Name" } }
    assert_redirected_to organization_path(@organization.slug)
    @organization.reload
    assert_not_equal "Hacked Name", @organization.name
  end

  test "update renders edit on validation failure" do
    sign_in_as(@user)
    patch organization_path(@organization.slug), params: { organization: { name: "" } }
    assert_response :unprocessable_entity
  end

  test "update with invalid URL shows error" do
    sign_in_as(@user)
    patch organization_path(@organization.slug), params: { organization: { website_url: "not-a-url" } }
    assert_response :unprocessable_entity
  end

  test "create cannot mass-assign discarded_at" do
    sign_in_as(@user)
    post organizations_path, params: { organization: { name: "Sneaky Org", discarded_at: "2026-01-01" } }
    org = Organization.find_by(slug: "sneaky-org")
    assert_not_nil org
    assert_nil org.discarded_at
  end

  test "update cannot mass-assign discarded_at" do
    sign_in_as(@user)
    patch organization_path(@organization.slug), params: { organization: { discarded_at: "2026-01-01" } }
    @organization.reload
    assert_nil @organization.discarded_at
  end

  test "create cannot mass-assign slug" do
    sign_in_as(@user)
    post organizations_path, params: { organization: { name: "Slug Test Org", slug: "hacked-slug" } }
    org = Organization.find_by(name: "Slug Test Org")
    assert_not_nil org
    assert_equal "slug-test-org", org.slug
  end
end
