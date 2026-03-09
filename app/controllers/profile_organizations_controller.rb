class ProfileOrganizationsController < ApplicationController
  def index
    @organizations = Current.user.organizations.kept.with_attached_logo
                                   .includes(listings: :interests).order(:name)
  end
end
