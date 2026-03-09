require "test_helper"

class Admin::ListingsControllerTest < ActionDispatch::IntegrationTest
  test "redirects non-admin users from index" do
    sign_in_as(users(:two))
    get admin_listings_path
    assert_redirected_to root_path
    assert_equal "Not authorized", flash[:alert]
  end

  test "admin can view all listings including discarded" do
    sign_in_as(users(:one))
    get admin_listings_path
    assert_response :success
    assert_select "td", text: listings(:open_listing).title
    assert_select "td", text: listings(:discarded_listing).title
  end

  test "admin can discard a listing" do
    sign_in_as(users(:one))
    listing = listings(:open_listing)
    assert listing.kept?

    patch admin_listing_path(listing), params: { discarded: "true" }
    assert_redirected_to admin_listings_path

    listing.reload
    assert listing.discarded?
  end

  test "admin can restore a discarded listing" do
    sign_in_as(users(:one))
    listing = listings(:discarded_listing)
    assert listing.discarded?

    patch admin_listing_path(listing), params: { discarded: "false" }
    assert_redirected_to admin_listings_path

    listing.reload
    assert listing.kept?
  end

  test "non-admin cannot discard a listing" do
    sign_in_as(users(:two))
    listing = listings(:open_listing)

    patch admin_listing_path(listing), params: { discarded: "true" }
    assert_redirected_to root_path

    listing.reload
    assert listing.kept?
  end
end
