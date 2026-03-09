require "test_helper"

class Admin::OrganizationsControllerTest < ActionDispatch::IntegrationTest
  test "redirects non-admin users from index" do
    sign_in_as(users(:two))
    get admin_organizations_path
    assert_redirected_to root_path
    assert_equal "Not authorized", flash[:alert]
  end

  test "admin can view all organizations including discarded" do
    sign_in_as(users(:one))
    get admin_organizations_path
    assert_response :success
    assert_select "td", text: organizations(:one).name
    assert_select "td", text: organizations(:discarded_org).name
  end

  test "admin can discard an organization" do
    sign_in_as(users(:one))
    org = organizations(:one)
    assert org.kept?

    patch admin_organization_path(org), params: { discarded: "true" }
    assert_redirected_to admin_organizations_path

    org.reload
    assert org.discarded?
  end

  test "admin can restore a discarded organization" do
    sign_in_as(users(:one))
    org = organizations(:discarded_org)
    assert org.discarded?

    patch admin_organization_path(org), params: { discarded: "false" }
    assert_redirected_to admin_organizations_path

    org.reload
    assert org.kept?
  end

  test "index paginates organizations" do
    sign_in_as(users(:one))

    # Create enough organizations to exceed one page (Pagy default is 20)
    25.times do |i|
      Organization.create!(name: "Paginated Org #{i}", slug: "paginated-org-#{i}")
    end

    get admin_organizations_path
    assert_response :success

    # Should have pagination nav rendered
    assert_select "nav[aria-label]"
  end

  test "non-admin cannot discard an organization" do
    sign_in_as(users(:two))
    org = organizations(:one)

    patch admin_organization_path(org), params: { discarded: "true" }
    assert_redirected_to root_path

    org.reload
    assert org.kept?
  end
end
