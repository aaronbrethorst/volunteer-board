require "test_helper"

class MembershipTest < ActiveSupport::TestCase
  test "valid membership" do
    # user two is not a member of discarded_org
    membership = Membership.new(user: users(:one), organization: organizations(:discarded_org), role: :member)
    assert membership.valid?
  end

  test "requires user" do
    membership = Membership.new(organization: organizations(:one), role: :member)
    assert_not membership.valid?
  end

  test "requires organization" do
    membership = Membership.new(user: users(:one), role: :member)
    assert_not membership.valid?
  end

  test "user_id and organization_id must be unique together" do
    existing = memberships(:owner_one)
    duplicate = Membership.new(user: existing.user, organization: existing.organization, role: :member)
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:user_id], "has already been taken"
  end

  test "role enum works" do
    membership = memberships(:owner_one)
    assert membership.owner?
    assert_not membership.member?

    membership = memberships(:member_two)
    assert membership.member?
    assert_not membership.owner?
  end

  test "default role is member" do
    membership = Membership.new
    assert membership.member?
  end
end
