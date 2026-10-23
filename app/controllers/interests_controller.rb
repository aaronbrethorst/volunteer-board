class InterestsController < ApplicationController
  allow_unauthenticated_access only: %i[new]

  before_action :set_listing
  before_action :require_open_listing, only: %i[new create]
  before_action :require_confirmed_email, only: %i[create]

  def index
    require_owner
    return if performed?

    @interests = @listing.interests.includes(:user).order(created_at: :desc)
  end

  def new
    if !authenticated?
      session[:return_to_after_authenticating] = request.url
      redirect_to new_session_path
    elsif @listing.interests.exists?(user: Current.user)
      redirect_to listing_path(@listing)
    else
      require_confirmed_email
    end
  end

  def create
    if @listing.interests.exists?(user: Current.user)
      redirect_to listing_path(@listing)
      return
    end

    @interest = @listing.interests.build(interest_params)
    @interest.user = Current.user
    @interest.save!
    NotifyOwnersOfInterest.new(@interest, exclude_user: Current.user).call
    redirect_to listing_path(@listing), notice: "Thanks for sharing your interest! We've shared your information with the organization."
  rescue ActiveRecord::RecordNotUnique
    redirect_to listing_path(@listing)
  end

  def show
    require_owner
    return if performed?

    @interest = @listing.interests.includes(:user).find(params[:id])
  end

  def destroy
    @interest = @listing.interests.find_by(user: Current.user)
    @interest&.destroy
    redirect_to listing_path(@listing)
  end

  private

  def set_listing
    @listing = Listing.visible.find(params[:listing_id])
  end

  def require_open_listing
    unless @listing.open?
      redirect_to listing_path(@listing), alert: "This listing is no longer accepting volunteers."
    end
  end

  # The volunteer's email becomes the Reply-To on owner notifications, so it
  # must be verified first.
  def require_confirmed_email
    unless Current.user.email_confirmed?
      redirect_to listing_path(@listing), alert: "Please confirm your email address before expressing interest."
    end
  end

  def require_owner
    unless Current.user && @listing.organization.memberships.exists?(user: Current.user, role: :owner)
      redirect_to listing_path(@listing), alert: "You are not authorized to perform this action."
    end
  end

  def interest_params
    params.expect(interest: [ :message ])
  end
end
