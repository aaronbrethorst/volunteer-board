class Interest < ApplicationRecord
  belongs_to :user
  belongs_to :listing

  validates :user_id, uniqueness: { scope: :listing_id }
  validates :message, length: { maximum: 2000 }, allow_blank: true
end
