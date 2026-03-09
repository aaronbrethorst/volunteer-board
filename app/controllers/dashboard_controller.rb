class DashboardController < ApplicationController
  def show
    @organizations = Current.user.organizations.kept.with_attached_logo.order(:name)
  end
end
