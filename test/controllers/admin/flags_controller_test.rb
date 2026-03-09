require "test_helper"

class Admin::FlagsControllerTest < ActionDispatch::IntegrationTest
  test "redirects non-admin users from index" do
    sign_in_as(users(:two))
    get admin_flags_path
    assert_redirected_to root_path
    assert_equal "Not authorized", flash[:alert]
  end

  test "admin sees unreviewed flags" do
    sign_in_as(users(:one))
    get admin_flags_path
    assert_response :success
    assert_select "td", text: /spam/i
  end

  test "admin can resolve a flag" do
    sign_in_as(users(:one))
    flag = flags(:org_flag)
    assert flag.unreviewed?

    patch admin_flag_path(flag)
    assert_redirected_to admin_flags_path

    flag.reload
    assert flag.resolved?
  end

  test "resolved flags not shown in index" do
    sign_in_as(users(:one))
    flags(:org_flag).resolved!
    flags(:listing_flag).resolved!

    get admin_flags_path
    assert_response :success
    assert_select "table", count: 0
  end
end
