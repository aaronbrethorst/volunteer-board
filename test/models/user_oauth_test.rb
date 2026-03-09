require "test_helper"

class UserOauthTest < ActiveSupport::TestCase
  test "github_linked? returns true when github_uid is present" do
    user = users(:one)
    user.github_uid = "12345"
    assert user.github_linked?
  end

  test "github_linked? returns false when github_uid is blank" do
    user = users(:one)
    user.github_uid = nil
    assert_not user.github_linked?
  end

  test "linkedin_linked? returns true when linkedin_uid is present" do
    user = users(:one)
    user.linkedin_uid = "67890"
    assert user.linkedin_linked?
  end

  test "linkedin_linked? returns false when linkedin_uid is blank" do
    user = users(:one)
    user.linkedin_uid = nil
    assert_not user.linkedin_linked?
  end

  test "user created via OAuth can have a random password" do
    user = User.create!(
      email_address: "oauthonly@example.com",
      name: "OAuth Only User",
      password: SecureRandom.hex(16),
      github_uid: "99999",
      github_username: "oauthonly"
    )
    assert user.persisted?
    assert user.github_linked?
  end
end
