require "test_helper"

class ListingCardComponentTest < ViewComponent::TestCase
  setup do
    @listing = listings(:open_listing)
  end

  test "renders listing title" do
    render_inline(ListingCardComponent.new(listing: @listing))

    assert_text @listing.title
  end

  test "renders organization name" do
    render_inline(ListingCardComponent.new(listing: @listing))

    assert_text @listing.organization.name
  end

  test "renders discipline badge" do
    render_inline(ListingCardComponent.new(listing: @listing))

    assert_selector "span", text: @listing.discipline.titleize
  end

  test "renders commitment when present" do
    render_inline(ListingCardComponent.new(listing: @listing))

    assert_text @listing.commitment
  end

  test "renders location when present" do
    render_inline(ListingCardComponent.new(listing: @listing))

    assert_text @listing.location
  end

  test "renders skills tags" do
    render_inline(ListingCardComponent.new(listing: @listing))

    @listing.skills.split(",").map(&:strip).first(4).each do |skill|
      assert_text skill
    end
  end

  test "links to the listing show page" do
    render_inline(ListingCardComponent.new(listing: @listing))

    assert_selector "a[href='#{listing_path(@listing)}']"
  end

  test "does not render commitment when blank" do
    @listing.commitment = nil
    render_inline(ListingCardComponent.new(listing: @listing))

    assert_no_text "hrs/week"
  end

  test "does not render location when blank" do
    @listing.location = nil
    render_inline(ListingCardComponent.new(listing: @listing))

    assert_no_text "Remote"
  end

  private

  def listing_path(listing)
    Rails.application.routes.url_helpers.listing_path(listing)
  end
end
