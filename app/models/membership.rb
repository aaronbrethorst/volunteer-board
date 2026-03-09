class Membership < ApplicationRecord
  belongs_to :user
  belongs_to :organization

  enum :role, { owner: 0, member: 1 }

  validates :user_id, uniqueness: { scope: :organization_id }
end
