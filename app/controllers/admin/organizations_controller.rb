class Admin::OrganizationsController < Admin::BaseController
  def index
    @pagy, @organizations = pagy(Organization.order(created_at: :desc))
  end

  def update
    @organization = Organization.find_by!(slug: params[:id])

    if params[:discarded] == "true"
      @organization.discard
    else
      @organization.undiscard
    end

    redirect_to admin_organizations_path, notice: "Organization updated."
  rescue ActiveRecord::RecordInvalid
    redirect_to admin_organizations_path, alert: "Failed to update organization."
  end
end
