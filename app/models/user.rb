class User < ApplicationRecord
  has_secure_password

  # Fingerprint: token is invalidated when email_confirmed_at changes,
  # ensuring single-use confirmation links.
  generates_token_for :email_confirmation, expires_in: 24.hours do
    email_confirmed_at
  end
  has_many :sessions, dependent: :destroy
  has_many :memberships, dependent: :destroy
  has_many :organizations, through: :memberships
  has_many :interests, dependent: :destroy
  has_many :flags, dependent: :destroy
  has_many :interested_listings, through: :interests, source: :listing

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :name, presence: true
  validates :email_address, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 8 }, if: -> { password.present? || new_record? }
  validates :portfolio_url, format: { with: /\Ahttps?:\/\/.+\z/i, message: "must be a valid URL" }, allow_blank: true

  def email_confirmed?
    email_confirmed_at.present?
  end

  def confirm_email!
    update_column(:email_confirmed_at, Time.current)
  end

  def github_linked?
    github_uid.present?
  end

  def linkedin_linked?
    linkedin_uid.present?
  end
end
