class ProfileListingsController < ApplicationController
  def index
    @interested_listings = Current.user.interested_listings.visible.includes(:organization)
  end
end
