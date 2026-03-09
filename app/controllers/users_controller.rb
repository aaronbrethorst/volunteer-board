class UsersController < ApplicationController
  allow_unauthenticated_access

  def show
    @user = User.find(params[:id])
  end
end
