class InterestsController < ApplicationController
  before_action :set_listing

  def create
    @interest = @listing.interests.find_or_create_by(user: Current.user)

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to listing_path(@listing) }
    end
  end

  def destroy
    @interest = @listing.interests.find_by(user: Current.user)
    @interest&.destroy

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to listing_path(@listing) }
    end
  end

  private

  def set_listing
    @listing = Listing.kept.find(params[:listing_id])
  end
end
