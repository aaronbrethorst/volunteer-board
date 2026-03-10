# Preview all emails at http://localhost:3000/rails/mailers/email_confirmation_mailer
class EmailConfirmationMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/email_confirmation_mailer/confirm
  def confirm
    EmailConfirmationMailer.confirm(User.take)
  end
end
