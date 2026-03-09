require "test_helper"

class DashboardControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @listing = listings(:open_listing)
  end

  test "show requires authentication" do
    get dashboard_path
    assert_redirected_to new_session_path
  end

  test "show renders successfully" do
    sign_in_as(@user)
    get dashboard_path
    assert_response :success
  end

  test "show links to interested listings page" do
    sign_in_as(@user)
    get dashboard_path
    assert_response :success
    assert_match profile_listings_path, response.body
  end

  test "show displays user's organizations" do
    sign_in_as(@user)
    get dashboard_path
    assert_response :success
    assert_match organizations(:one).name, response.body
  end

  test "show does not display organizations user doesn't belong to" do
    sign_in_as(@user)
    get dashboard_path
    assert_response :success
    assert_no_match organizations(:two).name, response.body
  end

  test "show does not display discarded organizations" do
    # Give user a membership in the discarded org
    Membership.create!(user: @user, organization: organizations(:discarded_org), role: :member)
    sign_in_as(@user)
    get dashboard_path
    assert_response :success
    assert_no_match organizations(:discarded_org).name, response.body
  end
end
