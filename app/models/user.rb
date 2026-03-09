class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :memberships, dependent: :destroy
  has_many :organizations, through: :memberships
  has_many :interests, dependent: :destroy
  has_many :interested_listings, through: :interests, source: :listing

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :name, presence: true
  validates :email_address, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 8 }, if: -> { password.present? || new_record? }
  validates :portfolio_url, format: { with: /\Ahttps?:\/\/.+\z/i, message: "must be a valid URL" }, allow_blank: true

  def github_linked?
    github_uid.present?
  end

  def linkedin_linked?
    linkedin_uid.present?
  end
end
