class OrganizationsController < ApplicationController
  allow_unauthenticated_access only: %i[index show]

  before_action :set_organization, only: %i[show edit update]
  before_action :require_owner, only: %i[edit update]

  def index
    @organizations = Organization.kept.order(created_at: :desc)
  end

  def show
  end

  def new
    @organization = Organization.new
  end

  def create
    @organization = Organization.new(organization_params)

    if @organization.save
      @organization.memberships.create!(user: Current.user, role: :owner)
      redirect_to organization_path(@organization.slug), notice: "Organization was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @organization.update(organization_params)
      redirect_to organization_path(@organization.slug), notice: "Organization was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_organization
    @organization = Organization.kept.find_by!(slug: params[:slug])
  end

  def require_owner
    unless Current.user && @organization.memberships.exists?(user: Current.user, role: :owner)
      redirect_to organization_path(@organization.slug), alert: "You are not authorized to perform this action."
    end
  end

  def organization_params
    params.require(:organization).permit(:name, :description, :website_url, :repo_url, :logo)
  end
end
