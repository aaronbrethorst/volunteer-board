require "test_helper"

class InterestsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @user_two = users(:two)
    @listing = listings(:open_listing)
  end

  # --- Create ---

  test "create requires authentication" do
    post listing_interest_path(@listing)
    assert_redirected_to new_session_path
  end

  test "create expresses interest in a listing" do
    sign_in_as(@user)
    assert_difference "Interest.count", 1 do
      post listing_interest_path(@listing)
    end
    assert Interest.exists?(user: @user, listing: @listing)
  end

  test "create redirects back to listing" do
    sign_in_as(@user)
    post listing_interest_path(@listing)
    assert_redirected_to listing_path(@listing)
  end

  test "create responds with turbo_stream format" do
    sign_in_as(@user)
    post listing_interest_path(@listing), as: :turbo_stream
    assert_response :success
  end

  test "create does not duplicate interest" do
    sign_in_as(@user)
    Interest.create!(user: @user, listing: @listing)
    assert_no_difference "Interest.count" do
      post listing_interest_path(@listing)
    end
  end

  test "create returns 404 for discarded listing" do
    sign_in_as(@user)
    post listing_interest_path(listings(:discarded_listing))
    assert_response :not_found
  end

  # --- Destroy ---

  test "destroy requires authentication" do
    delete listing_interest_path(@listing)
    assert_redirected_to new_session_path
  end

  test "destroy removes interest" do
    sign_in_as(@user)
    Interest.create!(user: @user, listing: @listing)
    assert_difference "Interest.count", -1 do
      delete listing_interest_path(@listing)
    end
    assert_not Interest.exists?(user: @user, listing: @listing)
  end

  test "destroy redirects back to listing" do
    sign_in_as(@user)
    Interest.create!(user: @user, listing: @listing)
    delete listing_interest_path(@listing)
    assert_redirected_to listing_path(@listing)
  end

  test "destroy responds with turbo_stream format" do
    sign_in_as(@user)
    Interest.create!(user: @user, listing: @listing)
    delete listing_interest_path(@listing), as: :turbo_stream
    assert_response :success
  end

  test "destroy is a no-op when no interest exists" do
    sign_in_as(@user)
    assert_no_difference "Interest.count" do
      delete listing_interest_path(@listing)
    end
    assert_redirected_to listing_path(@listing)
  end

  test "destroy returns 404 for discarded listing" do
    sign_in_as(@user)
    delete listing_interest_path(listings(:discarded_listing))
    assert_response :not_found
  end
end
