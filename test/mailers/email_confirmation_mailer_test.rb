require "test_helper"

class EmailConfirmationMailerTest < ActionMailer::TestCase
  setup do
    @user = users(:unconfirmed)
  end

  test "confirm email is sent to user's email address" do
    mail = EmailConfirmationMailer.confirm(@user)

    assert_equal [ @user.email_address ], mail.to
  end

  test "confirm email has correct subject" do
    mail = EmailConfirmationMailer.confirm(@user)

    assert_equal "Confirm your email address", mail.subject
  end

  test "confirm email body includes confirmation link" do
    mail = EmailConfirmationMailer.confirm(@user)

    assert_match "email_confirmations", mail.body.encoded
  end
end
