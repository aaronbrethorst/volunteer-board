require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  setup { @user = users(:one) }

  test "should get sign in form" do
    get new_session_path
    assert_response :success
    assert_select "form"
  end

  test "should sign in with valid credentials" do
    post session_path, params: { email_address: @user.email_address, password: "password" }

    assert_redirected_to root_path
    assert cookies[:session_id]
  end

  test "should not sign in with invalid credentials" do
    post session_path, params: { email_address: @user.email_address, password: "wrong" }

    assert_redirected_to new_session_path
    assert_equal "Try another email address or password.", flash[:alert]
  end

  test "should sign out" do
    sign_in_as(@user)

    delete session_path

    assert_redirected_to new_session_path
    assert_empty cookies[:session_id]
  end

  test "session cookie is not permanent" do
    post session_path, params: { email_address: @user.email_address, password: "password" }
    set_cookie = response.headers["Set-Cookie"]
    # Permanent cookies set max-age to 20 years (630720000).
    # We want a shorter-lived cookie (2 weeks = 1209600).
    assert_no_match(/max-age=6307/i, set_cookie.to_s, "Session cookie should not be permanent (20-year expiry)")
  end

  test "sign out with already-destroyed session record does not crash" do
    sign_in_as(@user)

    # Destroy the session record server-side (simulating expiry/admin action)
    # but keep the cookie so the request still authenticates
    session_record = Session.find_by(user: @user)
    session_record.destroy

    # Now attempt sign-out — Current.session will be nil after resume_session fails
    # This should handle the nil gracefully
    delete session_path
    assert_redirected_to new_session_path
  end
end
