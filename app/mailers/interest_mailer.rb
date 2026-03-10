class InterestMailer < ApplicationMailer
  def new_interest(interest, recipient)
    @interest = interest
    @listing = interest.listing
    @organization = @listing.organization
    @recipient = recipient
    @interest_url = listing_interest_detail_url(@listing, interest)

    mail subject: "New interest in #{@listing.title} (#{@organization.name})", to: recipient.email_address
  end
end
