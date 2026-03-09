class Admin::ListingsController < Admin::BaseController
  def index
    @pagy, @listings = pagy(Listing.includes(:organization).order(created_at: :desc))
  end

  def update
    @listing = Listing.find(params[:id])

    if params[:discarded] == "true"
      @listing.discard
    else
      @listing.undiscard
    end

    redirect_to admin_listings_path, notice: "Listing updated."
  rescue ActiveRecord::RecordInvalid
    redirect_to admin_listings_path, alert: "Failed to update listing."
  end
end
