class RegistrationsController < ApplicationController
  allow_unauthenticated_access
  rate_limit to: 10, within: 1.minute, only: :create, with: -> { redirect_to new_registration_path, alert: "Try again later." }

  def new
    @user = User.new
  end

  def create
    @user = User.new(registration_params)

    if @user.save
      start_new_session_for @user
      email_sent = begin
        EmailConfirmationMailer.confirm(@user).deliver_later
        true
      rescue ActiveJob::EnqueueError => e
        Rails.logger.error("Failed to enqueue confirmation email for user #{@user.id}: #{e.class} - #{e.message}")
        false
      end
      notice = if email_sent
        "Welcome to OSSVolunteers! Check your email for a confirmation link."
      else
        "Welcome to OSSVolunteers! We couldn't send the confirmation email — use the banner above to resend it."
      end
      redirect_to root_url, notice: notice
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def registration_params
    params.expect(user: [ :email_address, :password, :password_confirmation, :name ])
  end
end
