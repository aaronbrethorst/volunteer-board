class Organization < ApplicationRecord
  include Discardable

  has_one_attached :logo

  validate :logo_content_type_validation
  validate :logo_size_validation

  has_many :memberships, dependent: :destroy
  has_many :users, through: :memberships
  has_many :listings, dependent: :destroy
  has_many :flags, as: :flaggable, dependent: :destroy

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true,
    format: { with: /\A[a-z0-9]+(?:-[a-z0-9]+)*\z/, message: "must be lowercase alphanumeric with hyphens" }
  validates :website_url, format: { with: /\Ahttps?:\/\/.+\z/i, message: "must be a valid URL" }, allow_blank: true
  validates :repo_url, format: { with: /\Ahttps?:\/\/.+\z/i, message: "must be a valid URL" }, allow_blank: true

  before_validation :generate_slug, on: :create

  def to_param
    slug
  end

  private

  def generate_slug
    self.slug = name.parameterize if name.present? && slug.blank?
  end

  LOGO_CONTENT_TYPES = %w[image/png image/jpeg image/gif image/webp].freeze
  LOGO_MAX_SIZE = 5.megabytes

  def logo_content_type_validation
    return unless logo.attached?

    unless LOGO_CONTENT_TYPES.include?(logo.blob.content_type)
      errors.add(:logo, "is not a valid file type (allowed: PNG, JPEG, GIF, WEBP)")
    end
  end

  def logo_size_validation
    return unless logo.attached?

    if logo.blob.byte_size > LOGO_MAX_SIZE
      errors.add(:logo, "is too large (max 5 MB)")
    end
  end
end
