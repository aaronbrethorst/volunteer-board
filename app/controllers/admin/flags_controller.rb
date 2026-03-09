class Admin::FlagsController < Admin::BaseController
  def index
    @pagy, @flags = pagy(Flag.unreviewed.includes(:user, :flaggable).order(created_at: :desc))
  end

  def update
    flag = Flag.unreviewed.find(params[:id])
    flag.resolved!
    redirect_to admin_flags_path, notice: "Flag resolved."
  end
end
