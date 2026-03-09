class Listing < ApplicationRecord
  include Discardable

  belongs_to :organization

  has_rich_text :description

  enum :discipline, {
    engineering: 0,
    ux_design: 1,
    product: 2,
    marketing: 3,
    biz_dev: 4,
    sales: 5,
    devops: 6,
    documentation: 7,
    community: 8,
    other: 9
  }

  enum :status, { open: 0, filled: 1, closed: 2 }

  scope :open, -> { where(status: :open).kept }
  scope :chronologically, -> { order(created_at: :asc) }
  scope :reverse_chronologically, -> { order(created_at: :desc) }

  validates :title, presence: true
  validates :discipline, presence: true
end
