class Flag < ApplicationRecord
  belongs_to :user
  belongs_to :flaggable, polymorphic: true

  enum :status, { unreviewed: 0, resolved: 1 }

  validates :reason, presence: true, length: { maximum: 2000 }
  validates :user_id, uniqueness: { scope: [ :flaggable_type, :flaggable_id ] }
end
