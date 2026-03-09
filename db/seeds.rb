# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Site admin user
admin_password = ENV.fetch("ADMIN_PASSWORD") { SecureRandom.alphanumeric(24) }
admin = User.find_or_initialize_by(email_address: "admin@volunteerboard.org")
admin.update!(
  name: "Site Admin",
  password: admin_password,
  site_admin: true
)
puts "Site admin seeded: #{admin.email_address} (password: #{admin_password})"
