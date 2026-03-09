class Admin::UsersController < Admin::BaseController
  def index
    @pagy, @users = pagy(User.order(:name))
  end
end
