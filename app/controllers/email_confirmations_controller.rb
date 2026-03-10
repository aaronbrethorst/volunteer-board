class EmailConfirmationsController < ApplicationController
  allow_unauthenticated_access only: [ :show ]
  rate_limit to: 5, within: 1.minute, only: :create,
    with: -> { redirect_to root_url, alert: "Try again later." }

  def show
    user = User.find_by_token_for(:email_confirmation, params[:token])

    if user
      user.confirm_email!
      redirect_to root_url, notice: "Your email address has been confirmed."
    else
      resume_session
      if Current.user&.email_confirmed?
        redirect_to root_url, notice: "Your email address is already confirmed."
      else
        redirect_to root_url, alert: "Email confirmation link is invalid or has expired."
      end
    end
  end

  def create
    if Current.user.email_confirmed?
      return redirect_to root_url, notice: "Your email is already confirmed."
    end

    begin
      EmailConfirmationMailer.confirm(Current.user).deliver_later
      redirect_to root_url, notice: "Confirmation email has been resent."
    rescue ActiveJob::EnqueueError => e
      Rails.logger.error("Failed to enqueue confirmation email for user #{Current.user.id}: #{e.class} - #{e.message}")
      redirect_to root_url, alert: "We couldn't send the confirmation email right now. Please try again later."
    end
  end
end
