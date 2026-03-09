class ListingCardComponent < ViewComponent::Base
  def initialize(listing:)
    @listing = listing
  end
end
