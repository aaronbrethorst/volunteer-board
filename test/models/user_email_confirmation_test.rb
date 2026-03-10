require "test_helper"

class UserEmailConfirmationTest < ActiveSupport::TestCase
  setup do
    @user = users(:unconfirmed)
  end

  test "email_confirmed? returns false when email_confirmed_at is nil" do
    assert_not @user.email_confirmed?
  end

  test "email_confirmed? returns true when email_confirmed_at is set" do
    user = User.new(email_confirmed_at: 1.day.ago)
    assert user.email_confirmed?
  end

  test "confirm_email! sets email_confirmed_at" do
    assert_not @user.email_confirmed?
    @user.confirm_email!
    assert @user.email_confirmed?
    assert_in_delta Time.current, @user.email_confirmed_at, 2.seconds
  end

  test "generates email confirmation token" do
    token = @user.generate_token_for(:email_confirmation)
    assert_not_nil token
    assert_kind_of String, token
  end

  test "finds user by valid email confirmation token" do
    token = @user.generate_token_for(:email_confirmation)
    found = User.find_by_token_for(:email_confirmation, token)
    assert_equal @user, found
  end

  test "email confirmation token is invalidated after confirmation" do
    token = @user.generate_token_for(:email_confirmation)
    @user.confirm_email!

    found = User.find_by_token_for(:email_confirmation, token)
    assert_nil found
  end

  test "email confirmation token expires after 24 hours" do
    token = @user.generate_token_for(:email_confirmation)

    travel 25.hours do
      found = User.find_by_token_for(:email_confirmation, token)
      assert_nil found
    end
  end

  test "confirm_email! succeeds even if model validations would fail" do
    @user.update_column(:name, "")
    assert_not @user.valid?

    assert_nothing_raised { @user.confirm_email! }
    assert @user.reload.email_confirmed?
  end

  test "new users default to unconfirmed" do
    user = User.create!(
      email_address: "brand-new@example.com",
      password: "securepassword",
      name: "Brand New"
    )
    assert_nil user.email_confirmed_at
    assert_not user.email_confirmed?
  end
end
