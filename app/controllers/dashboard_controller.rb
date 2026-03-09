class DashboardController < ApplicationController
  def show
    @interested_listings = Current.user.interested_listings.kept.includes(:organization)
  end
end
