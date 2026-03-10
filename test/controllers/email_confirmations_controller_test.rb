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

  test "show with already-used token shows friendly message when user is logged in and confirmed" do
    token = @user.generate_token_for(:email_confirmation)
    @user.confirm_email!
    sign_in_as @user

    get email_confirmation_url(token)

    assert_redirected_to root_url
    assert_equal "Your email address is already confirmed.", flash[:notice]
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

    assert_enqueued_emails 0 do
      post email_confirmations_url
    end

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

  test "create handles email enqueue failure gracefully" do
    sign_in_as @user

    EmailConfirmationMailer.define_singleton_method(:confirm) { |_user| raise ActiveJob::EnqueueError, "queue down" }

    post email_confirmations_url

    assert_redirected_to root_url
    assert_match(/couldn.*send.*confirmation/i, flash[:alert])
  ensure
    EmailConfirmationMailer.singleton_class.remove_method(:confirm)
  end

  test "create has rate limiting configured" do
    # Verify rate_limit callback is registered on the create action
    callbacks = EmailConfirmationsController._process_action_callbacks.select { |cb|
      cb.kind == :before && cb.filter.to_s.include?("rate_limiting")
    }
    assert_not_empty callbacks, "Expected rate limiting before_action on EmailConfirmationsController"
  end

  test "create requires authentication" do
    post email_confirmations_url

    assert_redirected_to new_session_url
  end
end
