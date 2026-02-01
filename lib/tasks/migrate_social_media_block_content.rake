desc "Migrate social media service accounts to block content"
task migrate_social_media_block_content: :environment do
  mapping = {
    1 => "twitter",
    2 => "facebook",
    3 => "youtube",
    4 => "flickr",
    5 => "blog",
    6 => "pinterest",
    7 => "linkedin",
    8 => "google-plus",
    9 => "foursquare",
    10 => "email",
    11 => "other",
    12 => "instagram",
    13 => "bluesky",
    14 => "threads",
  }

  TopicalEvent.find_each do |event|
    puts "Checking TopicalEvent #{event.id} (#{event.slug})..."

    # Check for existing social media accounts (legacy)
    accounts = SocialMediaAccount.where(socialable: event).includes(:social_media_service)

    if accounts.any?
      puts "  Found #{accounts.count} legacy social media accounts."

      new_links = accounts.map { |account|
        service_id = account.social_media_service_id
        slug = mapping[service_id]

        unless slug
          puts "  WARNING: Unknown Service ID #{service_id} for account #{account.id}"
          next nil
        end

        {
          "social_media_service_id" => slug,
          "url" => account.url,
          "title" => account.title,
        }
      }.compact

      if new_links.any?
        # Merge with existing block_content if present
        current_content = event.block_content || {}
        current_content = current_content.to_h
        current_content["social_media_links"] = new_links
        event.block_content = current_content

        if event.save(validate: false)
          puts "  Migrated #{new_links.count} links to block_content."
        else
          puts "  Failed to save: #{event.errors.full_messages.join(', ')}"
        end
      end
    else
      puts "  No legacy accounts found."
    end
  end
end
