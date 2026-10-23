class Session < ApplicationRecord
  # Matches the session cookie's expiry, so a copied cookie stops working
  # server-side even if the client ignores the cookie's expiration.
  LIFETIME = 2.weeks

  belongs_to :user

  scope :active, -> { where(created_at: LIFETIME.ago..) }
end
