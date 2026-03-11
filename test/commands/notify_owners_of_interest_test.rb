require "test_helper"

class NotifyOwnersOfInterestTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper

  setup do
    @listing = listings(:open_listing)
    @volunteer = users(:two)
    @interest = Interest.create!(user: @volunteer, listing: @listing, message: "I'd love to help!")
  end

  test "sends email to all organization owners" do
    assert_enqueued_emails 2 do
      NotifyOwnersOfInterest.new(@interest).call
    end
  end

  test "excludes a specific user from notifications" do
    owner = users(:one)
    assert_enqueued_emails 1 do
      NotifyOwnersOfInterest.new(@interest, exclude_user: owner).call
    end
  end

  test "does not send email to non-owner members" do
    # users(:two) is a member (not owner) of org one
    assert_enqueued_emails 2 do
      NotifyOwnersOfInterest.new(@interest).call
    end
  end

  test "does not send email to owners with unconfirmed email" do
    users(:one).update_column(:email_confirmed_at, nil)

    assert_enqueued_emails 1 do
      NotifyOwnersOfInterest.new(@interest).call
    end
  end

  test "sends no emails when all owners have unconfirmed email" do
    users(:one).update_column(:email_confirmed_at, nil)
    users(:three).update_column(:email_confirmed_at, nil)

    assert_enqueued_emails 0 do
      NotifyOwnersOfInterest.new(@interest).call
    end
  end

  test "continues notifying remaining owners when one enqueue fails" do
    call_count = 0
    original = InterestMailer.method(:new_interest)

    InterestMailer.define_singleton_method(:new_interest) do |interest, recipient|
      call_count += 1
      raise ActiveJob::EnqueueError, "queue full" if call_count == 1
      original.call(interest, recipient)
    end

    assert_enqueued_emails 1 do
      NotifyOwnersOfInterest.new(@interest).call
    end
  ensure
    InterestMailer.define_singleton_method(:new_interest, original)
  end

  test "does not raise when mailer raises StandardError" do
    original = InterestMailer.method(:new_interest)
    InterestMailer.define_singleton_method(:new_interest) { |*, **| raise StandardError, "boom" }

    assert_nothing_raised do
      NotifyOwnersOfInterest.new(@interest).call
    end
  ensure
    InterestMailer.define_singleton_method(:new_interest, original)
  end
end
