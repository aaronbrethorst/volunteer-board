require "test_helper"

class EmailConfirmationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:unconfirmed)
  end

  # --- show (confirm via token) ---

  test "show with valid token confirms email" do
    token = @user.generate_token_for(:email_confirmation)

    get email_confirmation_url(token)

    assert_redirected_to root_url
    assert_equal "Your email address has been confirmed.", flash[:notice]
    assert @user.reload.email_confirmed?
  end

  test "show with invalid token redirects with alert" do
    get email_confirmation_url("bogus-token")

    assert_redirected_to root_url
    assert_equal "Email confirmation link is invalid or has expired.", flash[:alert]
  end

  test "show with expired token redirects with alert" do
    token = @user.generate_token_for(:email_confirmation)

    travel 25.hours do
      get email_confirmation_url(token)

      assert_redirected_to root_url
      assert_equal "Email confirmation link is invalid or has expired.", flash[:alert]
    end
  end

  test "show with already-used token redirects with alert" do
    token = @user.generate_token_for(:email_confirmation)
    @user.confirm_email!

    get email_confirmation_url(token)

    assert_redirected_to root_url
    assert_equal "Email confirmation link is invalid or has expired.", flash[:alert]
  end

  test "show does not require authentication" do
    token = @user.generate_token_for(:email_confirmation)

    get email_confirmation_url(token)

    assert_redirected_to root_url
    assert @user.reload.email_confirmed?
  end

  # --- create (resend confirmation) ---

  test "create resends confirmation email for authenticated unconfirmed user" do
    sign_in_as @user

    assert_enqueued_email_with EmailConfirmationMailer, :confirm, args: [ @user ] do
      post email_confirmations_url
    end

    assert_redirected_to root_url
    assert_equal "Confirmation email has been resent.", flash[:notice]
  end

  test "create for already confirmed user shows already confirmed notice" do
    sign_in_as users(:two)

    post email_confirmations_url

    assert_redirected_to root_url
    assert_equal "Your email is already confirmed.", flash[:notice]
  end

  # --- confirmation banner ---

  test "unconfirmed user sees confirmation banner" do
    sign_in_as @user

    get root_url

    assert_response :success
    assert_select "div.bg-yellow-50", /confirm your email/i
    assert_select "div.bg-yellow-50 button", /resend confirmation/i
  end

  test "confirmed user does not see confirmation banner" do
    sign_in_as users(:two)

    get root_url

    assert_response :success
    assert_select "div.bg-yellow-50", false
  end

  test "unauthenticated visitor does not see confirmation banner" do
    get root_url

    assert_response :success
    assert_select "div.bg-yellow-50", false
  end

  test "create requires authentication" do
    post email_confirmations_url

    assert_redirected_to new_session_url
  end
end
