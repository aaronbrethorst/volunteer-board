require "test_helper"

class InterestsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @user_two = users(:two)
    @listing = listings(:open_listing)
  end

  # --- New ---

  test "new redirects to sign-in when logged out and stores return URL" do
    get new_listing_interest_path(@listing)
    assert_redirected_to new_session_path
  end

  test "new renders form when authenticated" do
    sign_in_as(@user)
    get new_listing_interest_path(@listing)
    assert_response :success
  end

  test "new redirects to listing if already interested" do
    sign_in_as(@user)
    Interest.create!(user: @user, listing: @listing)
    get new_listing_interest_path(@listing)
    assert_redirected_to listing_path(@listing)
  end

  # --- Create ---

  test "create requires authentication" do
    post listing_interest_path(@listing)
    assert_redirected_to new_session_path
  end

  test "create expresses interest with a message" do
    sign_in_as(@user)
    assert_difference "Interest.count", 1 do
      post listing_interest_path(@listing), params: { interest: { message: "I'd love to help!" } }
    end
    interest = Interest.find_by(user: @user, listing: @listing)
    assert_equal "I'd love to help!", interest.message
    assert_redirected_to listing_path(@listing)
  end

  test "create works without a message" do
    sign_in_as(@user)
    assert_difference "Interest.count", 1 do
      post listing_interest_path(@listing), params: { interest: { message: "" } }
    end
    assert_redirected_to listing_path(@listing)
  end

  test "create sends notification email to organization owners" do
    sign_in_as(@user_two)
    owner = memberships(:owner_one).user

    assert_enqueued_email_with InterestMailer, :new_interest, args: ->(args) { args[1] == owner } do
      post listing_interest_path(@listing), params: { interest: { message: "Interested!" } }
    end
  end

  test "create does not notify the owner about their own interest" do
    sign_in_as(@user) # user one is the owner of org one
    assert_enqueued_emails 0 do
      post listing_interest_path(@listing), params: { interest: { message: "I'm the owner" } }
    end
  end

  test "create does not send notification to non-owner members" do
    sign_in_as(@user_two)

    assert_enqueued_emails 1 do
      post listing_interest_path(@listing), params: { interest: { message: "Hi" } }
    end
  end

  test "create prevents duplicates" do
    sign_in_as(@user)
    Interest.create!(user: @user, listing: @listing)
    assert_no_difference "Interest.count" do
      post listing_interest_path(@listing), params: { interest: { message: "duplicate" } }
    end
    assert_redirected_to listing_path(@listing)
  end

  test "create does not send email for duplicate interest" do
    sign_in_as(@user)
    Interest.create!(user: @user, listing: @listing)
    assert_enqueued_emails 0 do
      post listing_interest_path(@listing), params: { interest: { message: "duplicate" } }
    end
  end

  test "create returns 404 for discarded listing" do
    sign_in_as(@user)
    post listing_interest_path(listings(:discarded_listing)), params: { interest: { message: "" } }
    assert_response :not_found
  end

  # --- Show ---

  test "show requires authentication" do
    interest = Interest.create!(user: @user_two, listing: @listing)
    get listing_interest_detail_path(@listing, interest)
    assert_redirected_to new_session_path
  end

  test "show is accessible to org members" do
    interest = Interest.create!(user: @user_two, listing: @listing, message: "Hello!")
    sign_in_as(@user) # user one is a member of org one
    get listing_interest_detail_path(@listing, interest)
    assert_response :success
    assert_select "p", text: "Hello!"
  end

  test "show denies non-members" do
    listing = listings(:closed_listing) # org two
    interest = Interest.create!(user: @user, listing: listing)
    sign_in_as(@user) # user one is NOT a member of org two
    get listing_interest_detail_path(listing, interest)
    assert_redirected_to listing_path(listing)
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
    assert_redirected_to listing_path(@listing)
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
