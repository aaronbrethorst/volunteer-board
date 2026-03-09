module Organizations
  class ListingsController < ApplicationController
    before_action :set_organization
    before_action :require_membership

    def new
      @listing = @organization.listings.build
    end

    def create
      @listing = @organization.listings.build(listing_params)

      if @listing.save
        redirect_to listing_path(@listing), notice: "Listing was successfully created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    private

    def set_organization
      @organization = Organization.kept.find_by!(slug: params[:organization_slug])
    end

    def require_membership
      unless Current.user && @organization.memberships.exists?(user: Current.user)
        redirect_to organization_path(@organization.slug), alert: "You are not authorized to perform this action."
      end
    end

    def listing_params
      params.require(:listing).permit(:title, :discipline, :description, :commitment, :location, :skills, :status)
    end
  end
end
