require "test_helper"

class InterestMailerTest < ActionMailer::TestCase
  setup do
    @listing = listings(:open_listing)
    @owner = users(:one)
    @interested_user = users(:two)
    @interest = Interest.create!(user: @interested_user, listing: @listing, message: "I'd love to help!")
  end

  test "new_interest is sent to the recipient's email address" do
    mail = InterestMailer.new_interest(@interest, @owner)

    assert_equal [ @owner.email_address ], mail.to
  end

  test "new_interest has correct subject with listing title and org name" do
    mail = InterestMailer.new_interest(@interest, @owner)

    assert_equal "New interest in #{@listing.title} (#{@listing.organization.name})", mail.subject
  end

  test "new_interest body includes listing title and organization name" do
    mail = InterestMailer.new_interest(@interest, @owner)
    body = mail.body.encoded

    assert_match @listing.title, body
    assert_match @listing.organization.name, body
  end

  test "new_interest body includes link to interest details" do
    mail = InterestMailer.new_interest(@interest, @owner)
    body = mail.body.encoded

    assert_match %r{listings/#{@listing.id}/interests/#{@interest.id}}, body
  end

  test "new_interest body invites recipient to review the interest" do
    mail = InterestMailer.new_interest(@interest, @owner)
    assert_match "review their interest", mail.html_part.body.decoded
  end

  test "new_interest is multipart with both HTML and text parts" do
    mail = InterestMailer.new_interest(@interest, @owner)

    assert mail.multipart?, "Expected email to be multipart"
    assert_not_nil mail.html_part, "Expected an HTML part"
    assert_not_nil mail.text_part, "Expected a text part"
  end

  test "new_interest sets reply-to as the interested user's email" do
    mail = InterestMailer.new_interest(@interest, @owner)

    assert_equal [ @interested_user.email_address ], mail.reply_to
  end

  test "new_interest body includes the interested user's name" do
    mail = InterestMailer.new_interest(@interest, @owner)
    body = mail.body.encoded

    assert_match @interested_user.name, body
  end

  test "new_interest body includes the interest message" do
    mail = InterestMailer.new_interest(@interest, @owner)
    body = mail.body.encoded

    assert_match "I'd love to help!", body
  end

  test "new_interest body omits message section when message is blank" do
    @interest.update!(message: "")
    mail = InterestMailer.new_interest(@interest, @owner)
    body = mail.body.encoded

    assert_no_match "Their message", body
  end
end
