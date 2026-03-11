require "test_helper"

class ProfileListingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @listing = listings(:open_listing)
  end

  test "index requires authentication" do
    get profile_listings_path
    assert_redirected_to new_session_path
  end

  test "index renders successfully when authenticated" do
    sign_in_as(@user)
    get profile_listings_path
    assert_response :success
  end

  test "index displays listings user expressed interest in" do
    Interest.create!(user: @user, listing: @listing)
    sign_in_as(@user)
    get profile_listings_path
    assert_response :success
    assert_match @listing.title, response.body
  end

  test "index displays organization name for interested listings" do
    Interest.create!(user: @user, listing: @listing)
    sign_in_as(@user)
    get profile_listings_path
    assert_match @listing.organization.name, response.body
  end

  test "index displays discipline badge for interested listings" do
    Interest.create!(user: @user, listing: @listing)
    sign_in_as(@user)
    get profile_listings_path
    assert_match @listing.discipline.titleize, response.body
  end

  test "index does not display listings user has no interest in" do
    sign_in_as(@user)
    get profile_listings_path
    assert_response :success
    assert_no_match @listing.title, response.body
  end

  test "index shows empty state when no interests" do
    sign_in_as(@user)
    get profile_listings_path
    assert_match(/No applications yet/i, response.body)
  end

  test "index does not display discarded listings" do
    discarded = listings(:discarded_listing)
    Interest.create!(user: @user, listing: discarded)
    sign_in_as(@user)
    get profile_listings_path
    assert_no_match discarded.title, response.body
  end
end
