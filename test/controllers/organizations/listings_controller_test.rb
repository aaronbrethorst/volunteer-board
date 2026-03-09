require "test_helper"

class Organizations::ListingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user_one = users(:one)     # owner of org one
    @user_two = users(:two)     # member of org one, owner of org two
    @organization = organizations(:one)
  end

  # --- New ---

  test "new requires authentication" do
    get new_organization_listing_path(@organization.slug)
    assert_redirected_to new_session_path
  end

  test "new renders form for org member" do
    sign_in_as(@user_two) # member of org one
    get new_organization_listing_path(@organization.slug)
    assert_response :success
    assert_select "form"
  end

  test "new renders form for org owner" do
    sign_in_as(@user_one)
    get new_organization_listing_path(@organization.slug)
    assert_response :success
    assert_select "form"
  end

  test "new redirects non-member" do
    non_member = User.create!(name: "Non Member", email_address: "nonmember@example.com", password: "password123")
    sign_in_as(non_member)
    get new_organization_listing_path(@organization.slug)
    assert_redirected_to organization_path(@organization.slug)
  end

  test "new returns 404 for discarded organization" do
    sign_in_as(@user_one)
    get new_organization_listing_path(organizations(:discarded_org).slug)
    assert_response :not_found
  end

  # --- Create ---

  test "create requires authentication" do
    post organization_listings_path(@organization.slug), params: {
      listing: { title: "New Listing", discipline: "engineering" }
    }
    assert_redirected_to new_session_path
  end

  test "create succeeds for org member" do
    sign_in_as(@user_two)
    assert_difference "Listing.count", 1 do
      post organization_listings_path(@organization.slug), params: {
        listing: { title: "New Listing", discipline: "engineering", commitment: "~5 hrs/week" }
      }
    end

    listing = Listing.last
    assert_equal "New Listing", listing.title
    assert_equal @organization, listing.organization
    assert listing.engineering?
    assert listing.open?
    assert_redirected_to listing_path(listing)
  end

  test "create succeeds for org owner" do
    sign_in_as(@user_one)
    assert_difference "Listing.count", 1 do
      post organization_listings_path(@organization.slug), params: {
        listing: { title: "Owner Listing", discipline: "product" }
      }
    end

    listing = Listing.last
    assert_equal "Owner Listing", listing.title
    assert_redirected_to listing_path(listing)
  end

  test "create rejects non-member" do
    non_member = User.create!(name: "Non Member", email_address: "nonmember@example.com", password: "password123")
    sign_in_as(non_member)
    assert_no_difference "Listing.count" do
      post organization_listings_path(@organization.slug), params: {
        listing: { title: "Hacked Listing", discipline: "engineering" }
      }
    end
    assert_redirected_to organization_path(@organization.slug)
  end

  test "create renders new on validation failure" do
    sign_in_as(@user_one)
    assert_no_difference "Listing.count" do
      post organization_listings_path(@organization.slug), params: {
        listing: { title: "", discipline: "engineering" }
      }
    end
    assert_response :unprocessable_entity
  end

  test "create cannot mass-assign discarded_at" do
    sign_in_as(@user_one)
    post organization_listings_path(@organization.slug), params: {
      listing: { title: "Sneaky Listing", discipline: "engineering", discarded_at: "2026-01-01" }
    }
    listing = Listing.find_by(title: "Sneaky Listing")
    assert_not_nil listing
    assert_nil listing.discarded_at
  end

  test "create sets default location to Remote" do
    sign_in_as(@user_one)
    post organization_listings_path(@organization.slug), params: {
      listing: { title: "Remote Listing", discipline: "engineering" }
    }
    listing = Listing.find_by(title: "Remote Listing")
    assert_equal "Remote", listing.location
  end

  test "form includes rich text area for description" do
    sign_in_as(@user_one)
    get new_organization_listing_path(@organization.slug)
    assert_select "trix-editor"
  end

  test "form includes discipline select" do
    sign_in_as(@user_one)
    get new_organization_listing_path(@organization.slug)
    assert_select "select[name='listing[discipline]']"
  end
end
