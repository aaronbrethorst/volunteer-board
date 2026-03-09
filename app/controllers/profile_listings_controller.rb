class ProfileListingsController < ApplicationController
  def index
    @interested_listings = Current.user.interested_listings.kept.includes(:organization)
  end
end
