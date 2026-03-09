class ListingsController < ApplicationController
  allow_unauthenticated_access only: %i[show]

  before_action :set_listing
  before_action :require_membership, only: %i[edit update]

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
