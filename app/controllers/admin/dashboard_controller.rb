class Admin::DashboardController < Admin::BaseController
  def show
    @organizations_count = Organization.count
    @listings_count = Listing.count
    @users_count = User.count
    @discarded_organizations_count = Organization.discarded.count
    @discarded_listings_count = Listing.discarded.count
    @unreviewed_flags_count = Flag.unreviewed.count
  end
end
