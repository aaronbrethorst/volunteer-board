require "test_helper"

class DiscardableTest < ActiveSupport::TestCase
  setup do
    @kept_org = organizations(:one)
    @discarded_org = organizations(:discarded_org)
  end

  test "kept scope returns only non-discarded records" do
    kept = Organization.kept
    assert_includes kept, @kept_org
    assert_not_includes kept, @discarded_org
  end

  test "discarded scope returns only discarded records" do
    discarded = Organization.discarded
    assert_includes discarded, @discarded_org
    assert_not_includes discarded, @kept_org
  end

  test "discard sets discarded_at" do
    assert_nil @kept_org.discarded_at
    @kept_org.discard
    assert_not_nil @kept_org.reload.discarded_at
  end

  test "undiscard clears discarded_at" do
    assert_not_nil @discarded_org.discarded_at
    @discarded_org.undiscard
    assert_nil @discarded_org.reload.discarded_at
  end

  test "discarded? returns true for discarded records" do
    assert @discarded_org.discarded?
    assert_not @kept_org.discarded?
  end

  test "kept? returns true for kept records" do
    assert @kept_org.kept?
    assert_not @discarded_org.kept?
  end
end
