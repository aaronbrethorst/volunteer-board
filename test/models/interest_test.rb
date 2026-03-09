require "test_helper"

class InterestTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    @listing = listings(:open_listing)
  end

  test "valid interest" do
    interest = Interest.new(user: @user, listing: @listing)
    assert interest.valid?
  end

  test "requires user" do
    interest = Interest.new(listing: @listing)
    assert_not interest.valid?
  end

  test "requires listing" do
    interest = Interest.new(user: @user)
    assert_not interest.valid?
  end

  test "enforces uniqueness of user per listing" do
    Interest.create!(user: @user, listing: @listing)
    duplicate = Interest.new(user: @user, listing: @listing)
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:user_id], "has already been taken"
  end

  test "same user can express interest in different listings" do
    Interest.create!(user: @user, listing: @listing)
    other_interest = Interest.new(user: @user, listing: listings(:filled_listing))
    assert other_interest.valid?
  end

  test "user has_many interests" do
    Interest.create!(user: @user, listing: @listing)
    assert_includes @user.interests.map(&:listing), @listing
  end

  test "user has_many interested_listings" do
    Interest.create!(user: @user, listing: @listing)
    assert_includes @user.interested_listings, @listing
  end

  test "listing has_many interests" do
    Interest.create!(user: @user, listing: @listing)
    assert_includes @listing.interests.map(&:user), @user
  end

  test "listing has_many interested_users" do
    Interest.create!(user: @user, listing: @listing)
    assert_includes @listing.interested_users, @user
  end

  test "destroying user destroys interests" do
    user = User.create!(name: "Temp", email_address: "temp@example.com", password: "password123")
    Interest.create!(user: user, listing: @listing)
    assert_difference "Interest.count", -1 do
      user.destroy!
    end
  end

  test "destroying listing destroys interests" do
    listing = Listing.create!(title: "Temp", discipline: :engineering, organization: organizations(:one))
    Interest.create!(user: @user, listing: listing)
    assert_difference "Interest.count", -1 do
      listing.destroy!
    end
  end
end
