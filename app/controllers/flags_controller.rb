class FlagsController < ApplicationController
  before_action :set_flaggable

  def new
    @flag = @flaggable.flags.new
  end

  def create
    @flag = @flaggable.flags.new(flag_params)
    @flag.user = Current.user
    @flag.save!
    redirect_to flaggable_path, notice: "Thank you for your report. An admin will review it."
  rescue ActiveRecord::RecordNotUnique
    redirect_to flaggable_path, notice: "Thank you for your report. An admin will review it."
  rescue ActiveRecord::RecordInvalid
    render :new, status: :unprocessable_entity
  end

  private

  def set_flaggable
    if params[:organization_slug]
      @flaggable = Organization.kept.find_by!(slug: params[:organization_slug])
    elsif params[:listing_id]
      @flaggable = Listing.kept.find(params[:listing_id])
    else
      raise ActiveRecord::RecordNotFound
    end
  end

  def flag_params
    params.require(:flag).permit(:reason)
  end

  def flaggable_path
    case @flaggable
    when Organization
      organization_path(@flaggable.slug)
    when Listing
      listing_path(@flaggable)
    end
  end

  helper_method :flag_form_url

  def flag_form_url
    case @flaggable
    when Organization
      organization_flag_path(@flaggable.slug)
    when Listing
      listing_flag_path(@flaggable)
    end
  end
end
