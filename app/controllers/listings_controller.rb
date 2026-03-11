class ListingsController < ApplicationController
  allow_unauthenticated_access only: %i[index show]

  before_action :set_listing, only: %i[show edit update]
  before_action :require_membership, only: %i[edit update]

  def index
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

  def show
  end

  def edit
  end

  def update
    if @listing.update(listing_params)
      redirect_to listing_path(@listing), notice: "Listing was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_listing
    @listing = Listing.kept.find(params[:id])
  end

  def require_membership
    unless Current.user && @listing.organization.memberships.exists?(user: Current.user)
      redirect_to listing_path(@listing), alert: "You are not authorized to perform this action."
    end
  end

  def listing_params
    params.require(:listing).permit(:title, :discipline, :description, :commitment, :location, :skills, :status)
  end
end
