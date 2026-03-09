class Organization < ApplicationRecord
  include Discardable

  has_one_attached :logo

  has_many :memberships, dependent: :destroy
  has_many :users, through: :memberships

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true,
    format: { with: /\A[a-z0-9]+(?:-[a-z0-9]+)*\z/, message: "must be lowercase alphanumeric with hyphens" }
  validates :website_url, format: { with: /\Ahttps?:\/\/.+/i, message: "must be a valid URL" }, allow_blank: true
  validates :repo_url, format: { with: /\Ahttps?:\/\/.+/i, message: "must be a valid URL" }, allow_blank: true

  before_validation :generate_slug, on: :create

  def to_param
    slug
  end

  private

  def generate_slug
    self.slug = name.parameterize if name.present? && slug.blank?
  end
end
