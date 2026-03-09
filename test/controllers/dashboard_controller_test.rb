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

  test "show displays listings user expressed interest in" do
    sign_in_as(@user)
    Interest.create!(user: @user, listing: @listing)
    get dashboard_path
    assert_response :success
    assert_match @listing.title, response.body
  end

  test "show does not display listings user has no interest in" do
    sign_in_as(@user)
    get dashboard_path
    assert_response :success
    assert_no_match @listing.title, response.body
  end
end
