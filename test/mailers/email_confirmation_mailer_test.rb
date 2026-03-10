require "test_helper"

class EmailConfirmationMailerTest < ActionMailer::TestCase
  test "confirm email is sent to user's email address" do
    user = users(:one)
    user.update_column(:email_confirmed_at, nil)

    mail = EmailConfirmationMailer.confirm(user)

    assert_equal [ user.email_address ], mail.to
  end

  test "confirm email has correct subject" do
    user = users(:one)
    user.update_column(:email_confirmed_at, nil)

    mail = EmailConfirmationMailer.confirm(user)

    assert_equal "Confirm your email address", mail.subject
  end

  test "confirm email body includes confirmation link" do
    user = users(:one)
    user.update_column(:email_confirmed_at, nil)

    mail = EmailConfirmationMailer.confirm(user)

    assert_match "email_confirmations", mail.body.encoded
  end
end
