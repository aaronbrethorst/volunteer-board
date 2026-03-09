class OmniauthCallbacksController < ApplicationController
  allow_unauthenticated_access only: %i[create failure]
  rate_limit to: 10, within: 1.minute, only: :create, with: -> { redirect_to new_session_path, alert: "Try again later." }

  ALLOWED_PROVIDERS = %w[github linkedin].freeze

  def create
    auth = request.env["omniauth.auth"]

    if auth.nil?
      return redirect_to new_session_path, alert: "Authentication failed. Please try again."
    end

    if authenticated?
      link_account(auth)
    else
      sign_in_or_create(auth)
    end
  end

  def destroy
    provider = params[:provider]

    unless ALLOWED_PROVIDERS.include?(provider)
      return redirect_to edit_profile_path, alert: "Unknown provider. Not supported."
    end

    success = case provider
    when "github"
      Current.user.update(github_uid: nil, github_username: nil)
    when "linkedin"
      Current.user.update(linkedin_uid: nil, linkedin_username: nil)
    end

    if success
      redirect_to edit_profile_path, notice: "#{provider_display_name(provider)} account unlinked."
    else
      redirect_to edit_profile_path, alert: "Failed to unlink #{provider_display_name(provider)} account."
    end
  end

  def failure
    message = params[:message] || "unknown error"
    redirect_to new_session_path, alert: "Authentication failed: #{message}."
  end

  private

  def sign_in_or_create(auth)
    user = find_user_by_oauth(auth)

    unless user
      result = create_user_from_oauth(auth)

      case result
      in { user: created_user }
        user = created_user
      in { error: :email_taken }
        return redirect_to new_session_path, alert: "An account with this email already exists. Please sign in instead."
      in { error: :validation_failed, message: msg }
        Rails.logger.error("OAuth user creation failed: #{msg}")
        return redirect_to new_session_path, alert: "Authentication failed. Please try again."
      in { error: _ }
        return redirect_to new_session_path, alert: "Authentication failed. Please try again."
      end
    end

    if user&.persisted?
      start_new_session_for(user)
      redirect_to after_authentication_url
    else
      redirect_to new_session_path, alert: "Authentication failed. Please try again."
    end
  end

  def link_account(auth)
    provider = auth.provider
    uid = auth.uid

    # Check if this OAuth account is already linked to another user
    existing_user = find_user_by_oauth(auth)
    if existing_user && existing_user != Current.user
      return redirect_to edit_profile_path, alert: "That #{provider_display_name(provider)} account is already linked to another user."
    end

    success = case provider
    when "github"
      Current.user.update(
        github_uid: uid,
        github_username: auth.info.nickname
      )
    when "linkedin"
      Current.user.update(
        linkedin_uid: uid,
        linkedin_username: auth.info.try(:nickname) || linkedin_username_from(auth)
      )
    end

    if success
      redirect_to edit_profile_path, notice: "#{provider_display_name(provider)} account linked successfully."
    else
      redirect_to edit_profile_path, alert: "Failed to link #{provider_display_name(provider)} account."
    end
  end

  def find_user_by_oauth(auth)
    case auth.provider
    when "github"
      User.find_by(github_uid: auth.uid)
    when "linkedin"
      User.find_by(linkedin_uid: auth.uid)
    end
  end

  def create_user_from_oauth(auth)
    email = auth.info.email
    name = auth.info.name || "#{auth.info.first_name} #{auth.info.last_name}".strip

    return { error: :missing_email } if email.blank?

    attrs = {
      email_address: email,
      name: name,
      password: SecureRandom.hex(16)
    }

    case auth.provider
    when "github"
      attrs[:github_uid] = auth.uid
      attrs[:github_username] = auth.info.nickname
    when "linkedin"
      attrs[:linkedin_uid] = auth.uid
      attrs[:linkedin_username] = auth.info.try(:nickname) || linkedin_username_from(auth)
    end

    { user: User.create!(attrs) }
  rescue ActiveRecord::RecordNotUnique
    { error: :email_taken }
  rescue ActiveRecord::RecordInvalid => e
    if e.message.include?("Email address") && e.message.include?("taken")
      { error: :email_taken }
    else
      { error: :validation_failed, message: e.message }
    end
  end

  def linkedin_username_from(auth)
    # LinkedIn OpenID doesn't always provide a username/nickname
    auth.info.email&.split("@")&.first
  end

  PROVIDER_DISPLAY_NAMES = {
    "github" => "GitHub",
    "linkedin" => "LinkedIn"
  }.freeze

  def provider_display_name(provider)
    PROVIDER_DISPLAY_NAMES.fetch(provider, provider.capitalize)
  end
end
