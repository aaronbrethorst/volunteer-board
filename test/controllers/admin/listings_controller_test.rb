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

  test "admin listings index does not N+1 query for organizations" do
    sign_in_as(users(:one))

    # Warm up
    get admin_listings_path

    query_count = count_queries { get admin_listings_path }

    assert_response :success
    # With includes(:organization), query count should be bounded (not scale with number of listings)
    # Print for diagnostics, fail deliberately to see count
    # Without includes(:organization): 7 queries (4 listings × 1 org query each + auth).
    # With includes(:organization): should be <= 4 queries.
    assert query_count <= 6, "Expected <= 6 queries, got #{query_count} (possible N+1 on organization)"
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

  test "index paginates listings" do
    sign_in_as(users(:one))
    org = organizations(:one)

    # Create enough listings to exceed one page (Pagy default is 20)
    25.times do |i|
      Listing.create!(title: "Paginated Listing #{i}", discipline: :engineering, organization: org)
    end

    get admin_listings_path
    assert_response :success

    # Should have pagination nav rendered
    assert_select "nav[aria-label]"
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
