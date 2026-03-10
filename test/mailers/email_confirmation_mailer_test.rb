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

    assert_match %r{email_confirmations/[A-Za-z0-9\-_]+}, mail.body.encoded
  end

  test "confirm email mentions single-use and 24-hour expiry" do
    mail = EmailConfirmationMailer.confirm(@user)
    body = mail.body.encoded

    assert_match(/expire.*24 hours/i, body)
    assert_match(/only.*once/i, body)
  end
end
