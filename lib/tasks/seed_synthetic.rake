# frozen_string_literal: true

namespace :dev do
  desc "Generate synthetic data for development (users, orgs, listings, interests)"
  task seed: :environment do
    abort "This task can only be run in development!" unless Rails.env.development?

    puts "Seeding synthetic data..."

    # --- Realistic data pools ---

    first_names = %w[
      Aaliyah Aiden Amara Andre Beatriz Ben Camila Carlos Chen Clara
      Darius Diana Elena Ethan Fatima Felix Grace Harper Ibrahim Isla
      Jade James Jordan Kai Kenji Layla Leo Luna Maria Marcus Maya
      Milo Nadia Nathan Nia Noah Olivia Omar Priya Quinn Ravi Rosa
      Sam Sara Tao Uma Victor Willow Xiomara Yuki Zara
    ]

    last_names = %w[
      Alvarez Anderson Bai Brooks Campbell Chen Davis Diaz Evans Fischer
      Garcia Gonzalez Gupta Harris Hernandez Ibrahim Jackson Johnson Kim Lee
      Li Lopez Martin Mitchell Morales Murphy Nakamura Nguyen O'Brien Park
      Patel Peterson Ramirez Reed Robinson Rodriguez Santos Sharma Singh Smith
      Sullivan Taylor Thomas Thompson Torres Turner Walker Wang Williams Wilson
      Wright Yamamoto Young Zhang
    ]

    bios = [
      "Full-stack developer passionate about open source and community-driven projects.",
      "UX researcher with 5 years of experience in nonprofit digital products.",
      "Recently graduated CS student looking to contribute to meaningful projects.",
      "Product manager by day, volunteer coder by night. Love civic tech.",
      "Designer focused on accessibility and inclusive design principles.",
      "DevOps engineer interested in helping small orgs modernize their infrastructure.",
      "Technical writer who believes great docs make great software.",
      "Data scientist exploring how analytics can help nonprofits measure impact.",
      "Mobile developer with experience in React Native and Flutter.",
      "Marketing professional helping open-source projects reach wider audiences.",
      "Security researcher volunteering time to help nonprofits stay safe online.",
      "Backend engineer with deep Ruby and Python experience.",
      "Community organizer transitioning into tech. Eager to learn and contribute.",
      "Retired software architect mentoring the next generation of developers.",
      "Frontend developer specializing in performance optimization and modern CSS.",
      nil
    ]

    org_data = [
      { name: "Code for Community", desc: "Building open-source tools for local governments and civic engagement.", url: "https://codeforcommunity.org", repo: "https://github.com/codeforcommunity" },
      { name: "Shelter Connect", desc: "Technology solutions connecting homeless shelters with available resources and services.", url: "https://shelterconnect.org", repo: "https://github.com/shelterconnect" },
      { name: "Green Data Project", desc: "Open data platform tracking environmental metrics and climate action progress.", url: "https://greendataproject.org", repo: "https://github.com/greendataproject" },
      { name: "Teach Access", desc: "Empowering educators with accessible technology tools for inclusive classrooms.", url: "https://teachaccess.org", repo: "https://github.com/teachaccess" },
      { name: "Open Health Network", desc: "Volunteer-driven health information systems for underserved communities.", url: "https://openhealthnetwork.org", repo: nil },
      { name: "FoodShare Hub", desc: "Reducing food waste by connecting restaurants and grocery stores with food banks.", url: "https://foodsharehub.org", repo: "https://github.com/foodsharehub" },
      { name: "Trail Guardians", desc: "Mapping and maintaining public trail systems through citizen science and technology.", url: "https://trailguardians.org", repo: "https://github.com/trailguardians" },
      { name: "Literacy Bridge", desc: "Digital literacy programs and tools for adult learners and immigrants.", url: "https://literacybridge.org", repo: nil },
      { name: "Pet Rescue Network", desc: "Platform connecting animal shelters with potential adopters and foster families.", url: "https://petrescuenetwork.org", repo: "https://github.com/petrescuenetwork" },
      { name: "Civic Pulse", desc: "Data visualization tools for tracking local government spending and accountability.", url: "https://civicpulse.org", repo: "https://github.com/civicpulse" },
      { name: "Water Watch", desc: "Monitoring water quality in rural communities using IoT sensors and open data.", url: "https://waterwatch.org", repo: "https://github.com/waterwatch" },
      { name: "Neighbor Aid", desc: "Mutual aid platform helping neighbors share resources and skills.", url: "https://neighboraid.org", repo: nil },
      { name: "AccessMap", desc: "Crowdsourced accessibility mapping for wheelchair users and people with mobility challenges.", url: "https://accessmap.org", repo: "https://github.com/accessmap" },
      { name: "Crisis Text Line Tools", desc: "Open-source tools supporting mental health crisis intervention via text.", url: "https://crisistextlinetools.org", repo: "https://github.com/crisistextlinetools" },
      { name: "Open Ballot", desc: "Nonpartisan voter information and election transparency tools.", url: "https://openballot.org", repo: "https://github.com/openballot" },
      { name: "Youth Code Camp", desc: "Free coding workshops and mentorship for underrepresented youth in tech.", url: "https://youthcodecamp.org", repo: "https://github.com/youthcodecamp" },
      { name: "Farm to Table Tech", desc: "Connecting small farms with local buyers through logistics and inventory software.", url: "https://farmtotabletech.org", repo: nil },
      { name: "Disaster Ready", desc: "Emergency preparedness tools and communication systems for vulnerable communities.", url: "https://disasterready.org", repo: "https://github.com/disasterready" },
      { name: "Library Libre", desc: "Open-source library management systems for small and community libraries.", url: "https://librarylibre.org", repo: "https://github.com/librarylibre" },
      { name: "Justice Data Lab", desc: "Data analysis tools for criminal justice reform organizations.", url: "https://justicedatalab.org", repo: "https://github.com/justicedatalab" }
    ]

    listing_templates = {
      engineering: [
        { title: "Rails API Developer", skills: "Ruby, Rails, PostgreSQL", commitment: "5-10 hrs/week" },
        { title: "React Frontend Developer", skills: "React, TypeScript, CSS", commitment: "5-10 hrs/week" },
        { title: "Python Data Pipeline Engineer", skills: "Python, Pandas, Airflow", commitment: "3-5 hrs/week" },
        { title: "Mobile App Developer", skills: "React Native, iOS, Android", commitment: "8-12 hrs/week" },
        { title: "Backend API Developer", skills: "Node.js, Express, MongoDB", commitment: "5-10 hrs/week" },
        { title: "Full-Stack Web Developer", skills: "Ruby, Rails, Hotwire, Stimulus", commitment: "5-8 hrs/week" },
        { title: "Database Migration Specialist", skills: "PostgreSQL, MySQL, Data Migration", commitment: "3-5 hrs/week" },
        { title: "Embedded Systems Developer", skills: "C, Python, Raspberry Pi", commitment: "5-8 hrs/week" }
      ],
      ux_design: [
        { title: "UX Researcher", skills: "User interviews, Surveys, Analysis", commitment: "3-5 hrs/week" },
        { title: "UI Designer", skills: "Figma, Design Systems, Accessibility", commitment: "5-8 hrs/week" },
        { title: "Interaction Designer", skills: "Prototyping, Figma, User Testing", commitment: "4-6 hrs/week" },
        { title: "Visual Designer", skills: "Illustration, Branding, Figma", commitment: "3-5 hrs/week" }
      ],
      product: [
        { title: "Product Manager", skills: "Roadmapping, User Stories, Analytics", commitment: "5-8 hrs/week" },
        { title: "Agile Scrum Master", skills: "Scrum, Jira, Facilitation", commitment: "3-5 hrs/week" },
        { title: "Product Analyst", skills: "SQL, Analytics, A/B Testing", commitment: "4-6 hrs/week" }
      ],
      marketing: [
        { title: "Content Writer", skills: "Blog writing, SEO, Social media", commitment: "3-5 hrs/week" },
        { title: "Social Media Manager", skills: "Twitter, LinkedIn, Content Strategy", commitment: "2-4 hrs/week" },
        { title: "Email Marketing Specialist", skills: "Mailchimp, Copywriting, Analytics", commitment: "2-3 hrs/week" },
        { title: "Growth Marketing Lead", skills: "SEO, SEM, Content Marketing", commitment: "5-8 hrs/week" }
      ],
      biz_dev: [
        { title: "Partnership Coordinator", skills: "Outreach, Negotiation, CRM", commitment: "3-5 hrs/week" },
        { title: "Grant Writer", skills: "Grant Research, Proposal Writing", commitment: "5-10 hrs/week" },
        { title: "Fundraising Strategist", skills: "Donor Relations, Campaign Planning", commitment: "4-6 hrs/week" }
      ],
      devops: [
        { title: "CI/CD Pipeline Engineer", skills: "GitHub Actions, Docker, Linux", commitment: "3-5 hrs/week" },
        { title: "Cloud Infrastructure Engineer", skills: "AWS, Terraform, Kubernetes", commitment: "5-8 hrs/week" },
        { title: "Site Reliability Engineer", skills: "Monitoring, Alerting, Linux", commitment: "4-6 hrs/week" }
      ],
      documentation: [
        { title: "Technical Writer", skills: "Markdown, API Docs, Tutorials", commitment: "3-5 hrs/week" },
        { title: "Documentation Lead", skills: "Information Architecture, Style Guides", commitment: "4-6 hrs/week" },
        { title: "API Documentation Writer", skills: "OpenAPI, REST, Developer Experience", commitment: "3-5 hrs/week" }
      ],
      community: [
        { title: "Community Manager", skills: "Discord, Events, Onboarding", commitment: "5-8 hrs/week" },
        { title: "Volunteer Coordinator", skills: "Scheduling, Communication, Outreach", commitment: "3-5 hrs/week" },
        { title: "Mentorship Program Lead", skills: "Mentoring, Program Design", commitment: "4-6 hrs/week" }
      ],
      other: [
        { title: "Accessibility Auditor", skills: "WCAG, Screen Readers, Testing", commitment: "3-5 hrs/week" },
        { title: "Data Entry Volunteer", skills: "Spreadsheets, Attention to Detail", commitment: "2-4 hrs/week" },
        { title: "Translation Volunteer", skills: "Bilingual, Localization", commitment: "2-3 hrs/week" }
      ]
    }

    locations = [
      "Remote", "Remote", "Remote", "Remote",
      "Seattle, WA", "Portland, OR", "San Francisco, CA", "Los Angeles, CA",
      "New York, NY", "Chicago, IL", "Austin, TX", "Denver, CO",
      "Boston, MA", "Washington, DC", "Atlanta, GA", "Minneapolis, MN",
      "Hybrid — Seattle, WA", "Hybrid — New York, NY", "Hybrid — San Francisco, CA"
    ]

    listing_descriptions = [
      "<p>We're looking for a dedicated volunteer to help us build and maintain critical infrastructure. You'll work alongside a small but passionate team committed to making a difference.</p><p>This is a great opportunity to sharpen your skills while contributing to something meaningful. We value clear communication and reliability above all else.</p>",
      "<p>Join our team and help us ship features that directly impact thousands of users. We move fast, keep things simple, and celebrate small wins.</p><p>No prior nonprofit experience required — just bring your skills and enthusiasm. We'll handle the onboarding.</p>",
      "<p>We need someone who can own a piece of our stack end-to-end. You'll have real autonomy and the chance to shape our technical direction.</p><p>We meet weekly on Zoom and use GitHub for everything. Flexible schedule — work whenever it suits you.</p>",
      "<p>Help us improve our user experience and make our tools more accessible. We believe technology should work for everyone, not just the tech-savvy.</p><p>You'll collaborate with designers and developers to test, iterate, and ship improvements.</p>",
      "<p>This role involves a mix of hands-on work and strategic thinking. You'll help us figure out what to build next and why it matters.</p><p>We're a friendly, low-ego group. Newcomers are always welcome.</p>",
      "<p>We're tackling a big problem with a small team, and we need your help. Whether you can give 2 hours or 10, every contribution counts.</p><p>Our codebase is well-documented and our maintainers are responsive to questions. Great place to make your first open-source contribution.</p>"
    ]

    # --- Create Users ---

    print "Creating users..."
    users = []
    200.times do |i|
      puts "Creating users... #{i+1}/200"
      first = first_names.sample
      last = last_names.sample
      email = "#{first.downcase}.#{last.downcase.gsub("'", "")}+#{i}@example.com"
      user = User.create!(
        name: "#{first} #{last}",
        email_address: email,
        password: "password123",
        bio: bios.sample,
        portfolio_url: [ nil, nil, "https://#{first.downcase}#{last.downcase.gsub("'", "")}.dev", "https://github.com/#{first.downcase}#{last.downcase.gsub("'", "")}" ].sample,
        github_username: rand < 0.6 ? "#{first.downcase}#{last.downcase.gsub("'", "")}#{i}" : nil,
        linkedin_username: rand < 0.4 ? "#{first.downcase}-#{last.downcase.gsub("'", "")}-#{rand(1000)}" : nil,
        email_confirmed_at: Time.current
      )
      users << user
    end
    puts " #{users.size} created."

    # --- Create Organizations ---

    print "Creating organizations..."
    organizations = org_data.map do |data|
      Organization.create!(
        name: data[:name],
        description: data[:desc],
        website_url: data[:url],
        repo_url: data[:repo]
      )
    end
    puts " #{organizations.size} created."

    # --- Create Memberships ---

    print "Creating memberships..."
    membership_count = 0
    organizations.each do |org|
      # Each org gets 1-2 owners and 2-8 members
      owners = users.sample(rand(1..2))
      owners.each do |user|
        Membership.create!(user: user, organization: org, role: :owner)
        membership_count += 1
      end

      members = (users - owners).sample(rand(2..8))
      members.each do |user|
        Membership.create!(user: user, organization: org, role: :member)
        membership_count += 1
      rescue ActiveRecord::RecordInvalid
        next # skip duplicate memberships
      end
    end
    puts " #{membership_count} created."

    # --- Create Listings ---

    print "Creating listings..."
    listings = []
    organizations.each do |org|
      rand(3..8).times do
        discipline = listing_templates.keys.sample
        template = listing_templates[discipline].sample
        status = [ :open, :open, :open, :open, :filled, :closed ].sample

        listing = org.listings.create!(
          title: template[:title],
          discipline: discipline,
          skills: template[:skills],
          commitment: template[:commitment],
          location: locations.sample,
          status: status,
          created_at: rand(1..180).days.ago
        )
        listing.update!(description: listing_descriptions.sample)
        listings << listing
      end
    end
    puts " #{listings.size} created."

    # --- Create Interests ---

    print "Creating interests..."
    interest_count = 0
    open_listings = listings.select(&:open?)
    users.each do |user|
      interested_listings = open_listings.sample(rand(0..5))
      interested_listings.each do |listing|
        Interest.create!(user: user, listing: listing)
        interest_count += 1
      rescue ActiveRecord::RecordInvalid
        next # skip duplicates
      end
    end
    puts " #{interest_count} created."

    puts "\nDone! Created:"
    puts "  #{User.count} users"
    puts "  #{Organization.count} organizations"
    puts "  #{Membership.count} memberships"
    puts "  #{Listing.count} listings"
    puts "  #{Interest.count} interests"
  end
end
