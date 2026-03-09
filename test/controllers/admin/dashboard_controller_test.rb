require "test_helper"

class Admin::DashboardControllerTest < ActionDispatch::IntegrationTest
  test "redirects non-authenticated users" do
    get admin_root_path
    assert_redirected_to new_session_path
  end

  test "redirects non-admin users" do
    sign_in_as(users(:two))
    get admin_root_path
    assert_redirected_to root_path
    assert_equal "Not authorized", flash[:alert]
  end

  test "admin can access dashboard" do
    sign_in_as(users(:one))
    get admin_root_path
    assert_response :success
  end

  test "dashboard shows counts of orgs, listings, and users" do
    sign_in_as(users(:one))
    get admin_root_path
    assert_response :success
    assert_select "p.text-3xl", text: Organization.count.to_s
    assert_select "p.text-3xl", text: Listing.count.to_s
    assert_select "p.text-3xl", text: User.count.to_s
  end
end
