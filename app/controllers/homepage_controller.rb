class HomepageController < ApplicationController
  allow_unauthenticated_access

  def show
    listings = Listing.available.includes(:organization).reverse_chronologically

    if params[:discipline].present?
      listings = listings.where(discipline: params[:discipline])
    end

    if params[:query].present?
      search_term = "%#{ActiveRecord::Base.sanitize_sql_like(params[:query])}%"
      listings = listings.joins(:organization)
                         .where(
                           "listings.title ILIKE :q OR listings.skills ILIKE :q OR organizations.name ILIKE :q",
                           q: search_term
                         )
    end

    @pagy, @listings = pagy(listings)
  end
end
