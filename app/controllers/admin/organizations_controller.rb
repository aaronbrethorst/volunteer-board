class Admin::OrganizationsController < Admin::BaseController
  def index
    @organizations = Organization.order(created_at: :desc)
  end

  def update
    @organization = Organization.find_by!(slug: params[:id])

    if params[:discarded] == "true"
      @organization.discard
    else
      @organization.undiscard
    end

    redirect_to admin_organizations_path, notice: "Organization updated."
  end
end
