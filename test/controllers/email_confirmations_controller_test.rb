require "test_helper"

class EmailConfirmationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:two)
  end

  # --- show (confirm via token) ---

  test "show with valid token confirms email" do
    @user.update_column(:email_confirmed_at, nil)
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
    @user.update_column(:email_confirmed_at, nil)
    token = @user.generate_token_for(:email_confirmation)

    travel 25.hours do
      get email_confirmation_url(token)

      assert_redirected_to root_url
      assert_equal "Email confirmation link is invalid or has expired.", flash[:alert]
    end
  end

  test "show with already-used token redirects with alert" do
    @user.update_column(:email_confirmed_at, nil)
    token = @user.generate_token_for(:email_confirmation)
    @user.confirm_email!

    get email_confirmation_url(token)

    assert_redirected_to root_url
    assert_equal "Email confirmation link is invalid or has expired.", flash[:alert]
  end

  test "show does not require authentication" do
    @user.update_column(:email_confirmed_at, nil)
    token = @user.generate_token_for(:email_confirmation)

    get email_confirmation_url(token)

    assert_redirected_to root_url
    assert @user.reload.email_confirmed?
  end

  # --- create (resend confirmation) ---

  test "create resends confirmation email for authenticated unconfirmed user" do
    sign_in_as @user
    @user.update_column(:email_confirmed_at, nil)

    assert_enqueued_email_with EmailConfirmationMailer, :confirm, args: [ @user ] do
      post email_confirmations_url
    end

    assert_redirected_to root_url
    assert_equal "Confirmation email has been resent.", flash[:notice]
  end

  test "create for already confirmed user shows already confirmed notice" do
    sign_in_as @user

    post email_confirmations_url

    assert_redirected_to root_url
    assert_equal "Your email is already confirmed.", flash[:notice]
  end

  test "create requires authentication" do
    post email_confirmations_url

    assert_redirected_to new_session_url
  end
end
