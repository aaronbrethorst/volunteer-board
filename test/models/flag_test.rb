require "test_helper"

class FlagTest < ActiveSupport::TestCase
  test "valid flag" do
    flag = Flag.new(user: users(:one), flaggable: listings(:filled_listing), reason: "Inappropriate")
    assert flag.valid?
  end

  test "requires reason" do
    flag = Flag.new(user: users(:one), flaggable: listings(:filled_listing), reason: "")
    assert_not flag.valid?
    assert_includes flag.errors[:reason], "can't be blank"
  end

  test "uniqueness per user and flaggable" do
    flag = Flag.new(user: users(:two), flaggable: organizations(:one), reason: "Duplicate attempt")
    assert_not flag.valid?
    assert_includes flag.errors[:user_id], "has already been taken"
  end

  test "default status is unreviewed" do
    flag = Flag.new(user: users(:one), flaggable: listings(:filled_listing), reason: "Test")
    assert_equal "unreviewed", flag.status
  end

  test "can be resolved" do
    flag = flags(:org_flag)
    flag.resolved!
    assert flag.resolved?
  end
end
