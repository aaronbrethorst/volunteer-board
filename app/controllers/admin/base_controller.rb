class Admin::BaseController < ApplicationController
  layout "admin"
  before_action :require_admin

  private

  def require_admin
    unless Current.user&.site_admin?
      redirect_to root_path, alert: "Not authorized"
    end
  end
end
