# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Site admin user.
#
# Production requires ADMIN_EMAIL and ADMIN_PASSWORD (otherwise no admin is
# created) and never prints the password, since seeds run during deploys and
# their output lands in the logs. Elsewhere, defaults are used for convenience.
# An existing account is never modified, so re-seeding can't reset a password.
admin_email = ENV["ADMIN_EMAIL"].presence || ("admin@example.com" unless Rails.env.production?)
admin_password = ENV["ADMIN_PASSWORD"].presence || (SecureRandom.alphanumeric(24) unless Rails.env.production?)

if admin_email.nil? || admin_password.nil?
  puts "Skipping site admin seed: set ADMIN_EMAIL and ADMIN_PASSWORD to create one."
else
  admin = User.find_or_create_by!(email_address: admin_email) do |user|
    user.name = "Site Admin"
    user.password = admin_password
    user.site_admin = true
    user.email_confirmed_at = Time.current
  end

  if !admin.previously_new_record?
    puts "Site admin already exists, left unchanged: #{admin.email_address}"
  elsif Rails.env.production?
    puts "Site admin seeded: #{admin.email_address}"
  else
    puts "Site admin seeded: #{admin.email_address} (password: #{admin_password})"
  end
end
