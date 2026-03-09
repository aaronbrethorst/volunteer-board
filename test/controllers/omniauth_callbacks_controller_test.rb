require "test_helper"

class OmniauthCallbacksControllerTest < ActionDispatch::IntegrationTest
  setup do
    OmniAuth.config.test_mode = true

    @github_auth_hash = OmniAuth::AuthHash.new(
      provider: "github",
      uid: "12345",
      info: {
        email: "githubuser@example.com",
        name: "GitHub User",
        nickname: "ghuser"
      }
    )

    @linkedin_auth_hash = OmniAuth::AuthHash.new(
      provider: "linkedin",
      uid: "67890",
      info: {
        email: "linkedinuser@example.com",
        name: "LinkedIn User",
        first_name: "LinkedIn",
        last_name: "User"
      }
    )
  end

  teardown do
    OmniAuth.config.mock_auth[:github] = nil
    OmniAuth.config.mock_auth[:linkedin] = nil
  end

  # --- GitHub OAuth sign-in tests ---

  test "creates a new user and signs in via GitHub OAuth" do
    OmniAuth.config.mock_auth[:github] = @github_auth_hash

    assert_difference "User.count", 1 do
      get "/auth/github/callback"
    end

    user = User.find_by(github_uid: "12345")
    assert_not_nil user
    assert_equal "GitHub User", user.name
    assert_equal "githubuser@example.com", user.email_address
    assert_equal "ghuser", user.github_username
    assert_redirected_to root_url
    assert cookies[:session_id].present?
  end

  test "signs in existing user found by GitHub UID" do
    existing_user = users(:one)
    existing_user.update!(github_uid: "12345", github_username: "ghuser")

    OmniAuth.config.mock_auth[:github] = @github_auth_hash

    assert_no_difference "User.count" do
      get "/auth/github/callback"
    end

    assert_redirected_to root_url
    assert cookies[:session_id].present?
  end

  # --- LinkedIn OAuth sign-in tests ---

  test "creates a new user and signs in via LinkedIn OAuth" do
    OmniAuth.config.mock_auth[:linkedin] = @linkedin_auth_hash

    assert_difference "User.count", 1 do
      get "/auth/linkedin/callback"
    end

    user = User.find_by(linkedin_uid: "67890")
    assert_not_nil user
    assert_equal "LinkedIn User", user.name
    assert_equal "linkedinuser@example.com", user.email_address
    assert_redirected_to root_url
  end

  test "signs in existing user found by LinkedIn UID" do
    existing_user = users(:one)
    existing_user.update!(linkedin_uid: "67890", linkedin_username: "linkedinuser")

    OmniAuth.config.mock_auth[:linkedin] = @linkedin_auth_hash

    assert_no_difference "User.count" do
      get "/auth/linkedin/callback"
    end

    assert_redirected_to root_url
    assert cookies[:session_id].present?
  end

  # --- Account linking tests ---

  test "authenticated user links GitHub account" do
    user = users(:one)
    sign_in_as(user)

    OmniAuth.config.mock_auth[:github] = @github_auth_hash

    get "/auth/github/callback"

    user.reload
    assert_equal "12345", user.github_uid
    assert_equal "ghuser", user.github_username
    assert_redirected_to edit_profile_path
    assert_equal "GitHub account linked successfully.", flash[:notice]
  end

  test "authenticated user links LinkedIn account" do
    user = users(:one)
    sign_in_as(user)

    OmniAuth.config.mock_auth[:linkedin] = @linkedin_auth_hash

    get "/auth/linkedin/callback"

    user.reload
    assert_equal "67890", user.linkedin_uid
    assert_redirected_to edit_profile_path
    assert_equal "LinkedIn account linked successfully.", flash[:notice]
  end

  # --- Account unlinking tests ---

  test "authenticated user unlinks GitHub account" do
    user = users(:one)
    user.update!(github_uid: "12345", github_username: "ghuser")
    sign_in_as(user)

    delete "/auth/github"

    user.reload
    assert_nil user.github_uid
    assert_nil user.github_username
    assert_redirected_to edit_profile_path
    assert_equal "GitHub account unlinked.", flash[:notice]
  end

  test "authenticated user unlinks LinkedIn account" do
    user = users(:one)
    user.update!(linkedin_uid: "67890", linkedin_username: "linkedinuser")
    sign_in_as(user)

    delete "/auth/linkedin"

    user.reload
    assert_nil user.linkedin_uid
    assert_nil user.linkedin_username
    assert_redirected_to edit_profile_path
    assert_equal "LinkedIn account unlinked.", flash[:notice]
  end

  # --- Failure handling tests ---

  test "handles GitHub OAuth failure gracefully" do
    OmniAuth.config.mock_auth[:github] = :invalid_credentials

    get "/auth/github/callback"

    # OmniAuth redirects to /auth/failure, then our controller redirects to sign-in
    assert_redirected_to %r{/auth/failure}
    follow_redirect!
    assert_redirected_to new_session_path
    assert_match(/Authentication failed/, flash[:alert])
  end

  test "handles OAuth failure callback" do
    get "/auth/failure", params: { message: "invalid_credentials" }

    assert_redirected_to new_session_path
    assert_equal "Authentication failed: invalid_credentials.", flash[:alert]
  end

  # --- Edge case: missing email from OAuth ---

  test "does not create user when OAuth email is missing" do
    no_email_hash = OmniAuth::AuthHash.new(
      provider: "github",
      uid: "99999",
      info: {
        email: nil,
        name: "No Email User",
        nickname: "noemail"
      }
    )
    OmniAuth.config.mock_auth[:github] = no_email_hash

    assert_no_difference "User.count" do
      get "/auth/github/callback"
    end

    assert_redirected_to new_session_path
    assert_match(/Authentication failed/, flash[:alert])
  end

  # --- Edge case: unauthenticated unlink attempt ---

  test "unauthenticated user cannot unlink a provider" do
    delete "/auth/github"

    assert_redirected_to new_session_path
  end

  # --- Edge case: OAuth UID already linked to another user ---

  test "rejects linking GitHub if UID already belongs to another user" do
    other_user = users(:two)
    other_user.update!(github_uid: "12345", github_username: "ghuser")

    user = users(:one)
    sign_in_as(user)

    OmniAuth.config.mock_auth[:github] = @github_auth_hash

    get "/auth/github/callback"

    user.reload
    assert_nil user.github_uid
    assert_redirected_to edit_profile_path
    assert_match(/already linked/, flash[:alert])
  end
end
