require "test_helper"

class ListingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user_one = users(:one)     # owner of org one
    @user_two = users(:two)     # member of org one, owner of org two
    @organization = organizations(:one)
    @listing = listings(:open_listing)
  end

  # --- Show (public) ---

  test "show displays listing details" do
    get listing_path(@listing)
    assert_response :success
    assert_match @listing.title, response.body
  end

  test "show displays organization info" do
    get listing_path(@listing)
    assert_response :success
    assert_match @organization.name, response.body
  end

  test "show displays discipline" do
    get listing_path(@listing)
    assert_response :success
    assert_match "Engineering", response.body
  end

  test "show displays commitment" do
    get listing_path(@listing)
    assert_response :success
    assert_match @listing.commitment, response.body
  end

  test "show displays location" do
    get listing_path(@listing)
    assert_response :success
    assert_match @listing.location, response.body
  end

  test "show displays skills" do
    get listing_path(@listing)
    assert_response :success
    @listing.skills.split(",").map(&:strip).each do |skill|
      assert_match skill, response.body
    end
  end

  test "show displays status" do
    get listing_path(@listing)
    assert_response :success
    assert_match "Open", response.body
  end

  test "show returns 404 for nonexistent listing" do
    get listing_path(id: 999999)
    assert_response :not_found
  end

  test "show returns 404 for discarded listing" do
    get listing_path(listings(:discarded_listing))
    assert_response :not_found
  end

  # --- Edit ---

  test "edit requires authentication" do
    get edit_listing_path(@listing)
    assert_redirected_to new_session_path
  end

  test "edit is accessible to org owner" do
    sign_in_as(@user_one)
    get edit_listing_path(@listing)
    assert_response :success
    assert_select "form"
  end

  test "edit is accessible to org member" do
    sign_in_as(@user_two) # member of org one
    get edit_listing_path(@listing)
    assert_response :success
  end

  test "edit returns 404 for discarded listing" do
    sign_in_as(@user_one)
    get edit_listing_path(listings(:discarded_listing))
    assert_response :not_found
  end

  test "edit redirects non-member" do
    non_member = User.create!(name: "Non Member", email_address: "nonmember@example.com", password: "password123")
    sign_in_as(non_member)
    get edit_listing_path(@listing)
    assert_redirected_to listing_path(@listing)
  end

  # --- Update ---

  test "update requires authentication" do
    patch listing_path(@listing), params: { listing: { title: "Updated" } }
    assert_redirected_to new_session_path
  end

  test "update succeeds for org member" do
    sign_in_as(@user_two) # member of org one
    patch listing_path(@listing), params: { listing: { title: "Updated Title" } }
    assert_redirected_to listing_path(@listing)
    @listing.reload
    assert_equal "Updated Title", @listing.title
  end

  test "update succeeds for org owner" do
    sign_in_as(@user_one)
    patch listing_path(@listing), params: { listing: { title: "Owner Updated" } }
    assert_redirected_to listing_path(@listing)
    @listing.reload
    assert_equal "Owner Updated", @listing.title
  end

  test "update returns 404 for discarded listing" do
    sign_in_as(@user_one)
    patch listing_path(listings(:discarded_listing)), params: { listing: { title: "Updated" } }
    assert_response :not_found
  end

  test "update rejects non-member" do
    non_member = User.create!(name: "Non Member", email_address: "nonmember@example.com", password: "password123")
    sign_in_as(non_member)
    patch listing_path(@listing), params: { listing: { title: "Hacked" } }
    assert_redirected_to listing_path(@listing)
    @listing.reload
    assert_not_equal "Hacked", @listing.title
  end

  test "update renders edit on validation failure" do
    sign_in_as(@user_one)
    patch listing_path(@listing), params: { listing: { title: "" } }
    assert_response :unprocessable_entity
  end

  test "update cannot mass-assign organization_id" do
    sign_in_as(@user_one)
    other_org = organizations(:two)
    patch listing_path(@listing), params: { listing: { organization_id: other_org.id } }
    @listing.reload
    assert_equal @organization.id, @listing.organization_id
  end

  test "update cannot mass-assign discarded_at" do
    sign_in_as(@user_one)
    patch listing_path(@listing), params: { listing: { discarded_at: "2026-01-01" } }
    @listing.reload
    assert_nil @listing.discarded_at
  end

  # --- Interest button and count ---

  test "show displays interest count" do
    Interest.create!(user: @user_two, listing: @listing)
    get listing_path(@listing)
    assert_response :success
    assert_match "1 person interested", response.body
  end

  test "show displays I'm Interested button for authenticated user" do
    sign_in_as(@user_two)
    get listing_path(@listing)
    assert_response :success
    assert_select "a", text: "I'm Interested"
  end

  test "show displays Remove Interest button when already interested" do
    sign_in_as(@user_two)
    Interest.create!(user: @user_two, listing: @listing)
    get listing_path(@listing)
    assert_response :success
    assert_match "Remove Interest", response.body
  end

  test "show displays interested users for org members" do
    sign_in_as(@user_one) # owner of org one
    Interest.create!(user: @user_two, listing: @listing)
    get listing_path(@listing)
    assert_response :success
    assert_match @user_two.name, response.body
  end

  test "show does not N+1 query for interested users" do
    sign_in_as(@user_one)
    # Create 3 interested users
    user_three = User.create!(name: "User Three", email_address: "three@example.com", password: "password123")
    user_four = User.create!(name: "User Four", email_address: "four@example.com", password: "password123")
    Interest.create!(user: @user_two, listing: @listing)
    Interest.create!(user: user_three, listing: @listing)
    Interest.create!(user: user_four, listing: @listing)

    # Warm up (load schema, etc.)
    get listing_path(@listing)
    count_with_three = count_queries { get listing_path(@listing) }

    # Add 2 more interested users
    user_five = User.create!(name: "User Five", email_address: "five@example.com", password: "password123")
    user_six = User.create!(name: "User Six", email_address: "six@example.com", password: "password123")
    Interest.create!(user: user_five, listing: @listing)
    Interest.create!(user: user_six, listing: @listing)

    count_with_five = count_queries { get listing_path(@listing) }

    assert_response :success
    assert_match "User Five", response.body
    assert_match "User Six", response.body
    # If eager-loaded, adding more users should not increase query count
    assert_equal count_with_three, count_with_five,
      "Query count grew from #{count_with_three} to #{count_with_five} with more users (N+1)"
  end

  test "show does not display interested users for non-members" do
    non_member = User.create!(name: "Non Member", email_address: "nonmember@example.com", password: "password123")
    sign_in_as(non_member)
    Interest.create!(user: @user_two, listing: @listing)
    get listing_path(@listing)
    assert_response :success
    # Should see interest count but not the list of interested users
    assert_no_match "Interested Volunteers", response.body
  end
end
