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
    notify_organization_owners(@interest)
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

  def notify_organization_owners(interest)
    interest.listing.organization.memberships.where(role: :owner).where.not(user: Current.user).includes(:user).find_each do |membership|
      InterestMailer.new_interest(interest, membership.user).deliver_later
    rescue ActiveJob::EnqueueError => e
      Rails.logger.error("Failed to enqueue interest notification for user #{membership.user_id}: #{e.class} - #{e.message}")
    end
  end
end
