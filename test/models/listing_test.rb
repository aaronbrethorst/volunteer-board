require "test_helper"

class ListingTest < ActiveSupport::TestCase
  setup do
    @organization = organizations(:one)
    @listing = listings(:open_listing)
  end

  # --- Validations ---

  test "valid listing" do
    assert @listing.valid?
  end

  test "requires title" do
    @listing.title = nil
    assert_not @listing.valid?
    assert_includes @listing.errors[:title], "can't be blank"
  end

  test "requires discipline" do
    @listing.discipline = nil
    assert_not @listing.valid?
    assert_includes @listing.errors[:discipline], "can't be blank"
  end

  test "belongs to organization" do
    assert_equal @organization, @listing.organization
  end

  # --- Enums ---

  test "discipline enum values" do
    expected = {
      "engineering" => 0, "ux_design" => 1, "product" => 2,
      "marketing" => 3, "biz_dev" => 4, "sales" => 5,
      "devops" => 6, "documentation" => 7, "community" => 8, "other" => 9
    }
    assert_equal expected, Listing.disciplines
  end

  test "status enum values" do
    expected = { "open" => 0, "filled" => 1, "closed" => 2 }
    assert_equal expected, Listing.statuses
  end

  test "default status is open" do
    listing = Listing.new(title: "Test", discipline: :engineering, organization: @organization)
    assert listing.open?
  end

  test "default location is Remote" do
    listing = Listing.new(title: "Test", discipline: :engineering, organization: @organization)
    assert_equal "Remote", listing.location
  end

  # --- Scopes ---

  test "available scope returns only open and kept listings" do
    available_listings = Listing.available
    assert_includes available_listings, listings(:open_listing)
    assert_not_includes available_listings, listings(:filled_listing)
    assert_not_includes available_listings, listings(:closed_listing)
    assert_not_includes available_listings, listings(:discarded_listing)
  end

  test "available scope excludes discarded listings" do
    @listing.discard
    assert_not_includes Listing.available, @listing
  end

  test "chronologically orders by created_at asc" do
    # Verify the scope applies correct ordering
    relation = Listing.chronologically
    assert_equal :asc, relation.order_values.first.direction
  end

  test "reverse_chronologically orders by created_at desc" do
    relation = Listing.reverse_chronologically
    assert_equal :desc, relation.order_values.first.direction
  end

  # --- Discardable ---

  test "includes Discardable" do
    assert Listing.included_modules.include?(Discardable)
  end

  test "can be discarded and undiscarded" do
    @listing.discard
    assert @listing.discarded?
    assert_not_includes Listing.kept, @listing

    @listing.undiscard
    assert @listing.kept?
    assert_includes Listing.kept, @listing
  end

  # --- Rich Text ---

  test "has rich text description" do
    @listing.description = "<h1>Hello</h1>"
    @listing.save!
    assert_equal "<h1>Hello</h1>", @listing.description.body.to_html.strip
  end

  # --- Association ---

  test "organization has many listings" do
    assert_includes @organization.listings, @listing
  end

  test "destroying organization destroys listings" do
    org = organizations(:one)
    listing_ids = org.listings.pluck(:id)
    assert listing_ids.any?

    org.destroy
    listing_ids.each do |id|
      assert_nil Listing.find_by(id: id)
    end
  end
end
