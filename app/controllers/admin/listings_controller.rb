class Admin::ListingsController < Admin::BaseController
  def index
    @listings = Listing.order(created_at: :desc)
  end

  def update
    @listing = Listing.find(params[:id])

    if params[:discarded] == "true"
      @listing.discard
    else
      @listing.undiscard
    end

    redirect_to admin_listings_path, notice: "Listing updated."
  end
end
