require "test_helper"

class ProfileOrganizationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
  end

  test "index requires authentication" do
    get profile_organizations_path
    assert_redirected_to new_session_path
  end

  test "index renders successfully" do
    sign_in_as(@user)
    get profile_organizations_path
    assert_response :success
  end

  test "index links to applied listings page" do
    sign_in_as(@user)
    get profile_organizations_path
    assert_response :success
    assert_match profile_listings_path, response.body
  end

  test "index displays user's organizations" do
    sign_in_as(@user)
    get profile_organizations_path
    assert_response :success
    assert_match organizations(:one).name, response.body
  end

  test "index does not display organizations user doesn't belong to" do
    sign_in_as(@user)
    get profile_organizations_path
    assert_response :success
    assert_no_match organizations(:two).name, response.body
  end

  test "index does not display discarded organizations" do
    Membership.create!(user: @user, organization: organizations(:discarded_org), role: :member)
    sign_in_as(@user)
    get profile_organizations_path
    assert_response :success
    assert_no_match organizations(:discarded_org).name, response.body
  end

  test "index shows listings for user's organizations" do
    sign_in_as(@user)
    get profile_organizations_path
    assert_response :success
    assert_match listings(:open_listing).title, response.body
    assert_match listings(:filled_listing).title, response.body
  end

  test "index does not show discarded listings" do
    sign_in_as(@user)
    get profile_organizations_path
    assert_response :success
    assert_no_match listings(:discarded_listing).title, response.body
  end

  test "index shows listing status" do
    sign_in_as(@user)
    get profile_organizations_path
    assert_match "Open", response.body
    assert_match "Filled", response.body
  end

  test "index shows application count for listings" do
    listing = listings(:open_listing)
    Interest.create!(user: users(:two), listing: listing)
    sign_in_as(@user)
    get profile_organizations_path
    assert_match(/1\s+application/i, response.body)
  end

  test "index shows listing creation date" do
    sign_in_as(@user)
    get profile_organizations_path
    listing = listings(:open_listing)
    assert_match listing.created_at.strftime("%b %-d, %Y"), response.body
  end

  test "index links listings to their show page" do
    sign_in_as(@user)
    get profile_organizations_path
    assert_select "a[href=?]", listing_path(listings(:open_listing))
  end
end
