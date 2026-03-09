require "test_helper"

class FlagsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @organization = organizations(:one)
    @listing = listings(:open_listing)
  end

  # --- Authentication ---

  test "new organization flag redirects when unauthenticated" do
    get new_organization_flag_path(@organization.slug)
    assert_redirected_to new_session_path
  end

  test "create organization flag redirects when unauthenticated" do
    post organization_flag_path(@organization.slug), params: { flag: { reason: "Spam" } }
    assert_redirected_to new_session_path
  end

  test "new listing flag redirects when unauthenticated" do
    get new_listing_flag_path(@listing)
    assert_redirected_to new_session_path
  end

  test "create listing flag redirects when unauthenticated" do
    post listing_flag_path(@listing), params: { flag: { reason: "Spam" } }
    assert_redirected_to new_session_path
  end

  # --- Organization flags ---

  test "authenticated user can view new organization flag form" do
    sign_in_as(@user)
    get new_organization_flag_path(@organization.slug)
    assert_response :success
  end

  test "authenticated user can flag an organization" do
    sign_in_as(@user)
    assert_difference "Flag.count", 1 do
      post organization_flag_path(@organization.slug), params: { flag: { reason: "This is spam" } }
    end
    assert_redirected_to organization_path(@organization.slug)
  end

  # --- Listing flags ---

  test "authenticated user can view new listing flag form" do
    sign_in_as(@user)
    get new_listing_flag_path(@listing)
    assert_response :success
  end

  test "authenticated user can flag a listing" do
    sign_in_as(@user)
    assert_difference "Flag.count", 1 do
      post listing_flag_path(@listing), params: { flag: { reason: "Inappropriate content" } }
    end
    assert_redirected_to listing_path(@listing)
  end

  # --- Validations ---

  test "create fails without reason" do
    sign_in_as(@user)
    assert_no_difference "Flag.count" do
      post organization_flag_path(@organization.slug), params: { flag: { reason: "" } }
    end
    assert_response :unprocessable_entity
  end

  test "duplicate flag is prevented" do
    sign_in_as(users(:two))
    assert_no_difference "Flag.count" do
      post organization_flag_path(@organization.slug), params: { flag: { reason: "Another reason" } }
    end
    assert_response :unprocessable_entity
  end

  # --- 404 for discarded ---

  test "returns 404 for discarded organization" do
    sign_in_as(@user)
    get new_organization_flag_path(organizations(:discarded_org).slug)
    assert_response :not_found
  end

  test "returns 404 for discarded listing" do
    sign_in_as(@user)
    get new_listing_flag_path(listings(:discarded_listing))
    assert_response :not_found
  end
end
