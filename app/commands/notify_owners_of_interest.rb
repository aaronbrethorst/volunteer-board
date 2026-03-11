class NotifyOwnersOfInterest
  def initialize(interest, exclude_user: nil)
    @interest = interest
    @exclude_user = exclude_user
  end

  def call
    owner_memberships.find_each do |membership|
      InterestMailer.new_interest(@interest, membership.user).deliver_later
    rescue ActiveJob::EnqueueError => e
      Rails.logger.error("Failed to enqueue interest notification for user #{membership.user_id}: #{e.class} - #{e.message}")
    end
  rescue StandardError => e
    Rails.logger.error("Failed to notify organization owners for interest #{@interest.id}: #{e.class} - #{e.message}")
  end

  private

  def owner_memberships
    scope = @interest.listing.organization.memberships.where(role: :owner).includes(:user)
    scope = scope.where.not(user: @exclude_user) if @exclude_user
    scope.where(user: User.where.not(email_confirmed_at: nil))
  end
end
