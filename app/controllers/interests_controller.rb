class InterestsController < ApplicationController
  allow_unauthenticated_access only: %i[new]

  before_action :set_listing

  def new
    if !authenticated?
      session[:return_to_after_authenticating] = request.url
      redirect_to new_session_path
    elsif @listing.interests.exists?(user: Current.user)
      redirect_to listing_path(@listing)
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
    redirect_to listing_path(@listing)
  rescue ActiveRecord::RecordNotUnique
    redirect_to listing_path(@listing)
  end

  def show
    @interest = @listing.interests.find(params[:id])

    unless @listing.organization.memberships.exists?(user: Current.user)
      redirect_to listing_path(@listing)
    end
  end

  def destroy
    @interest = @listing.interests.find_by(user: Current.user)
    @interest&.destroy
    redirect_to listing_path(@listing)
  end

  private

  def set_listing
    @listing = Listing.kept.find(params[:listing_id])
  end

  def interest_params
    params.expect(interest: [ :message ])
  end
end
