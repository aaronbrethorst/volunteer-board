class HomepageController < ApplicationController
  allow_unauthenticated_access

  def show
    listings = Listing.open.includes(:organization).reverse_chronologically

    if params[:discipline].present?
      listings = listings.where(discipline: params[:discipline])
    end

    if params[:query].present?
      search_term = "%#{params[:query]}%"
      listings = listings.joins(:organization)
                         .where(
                           "listings.title LIKE :q OR listings.skills LIKE :q OR organizations.name LIKE :q",
                           q: search_term
                         )
    end

    @pagy, @listings = pagy(listings)
  end
end
