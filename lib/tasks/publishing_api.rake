require "gds_api/publishing_api/special_route_publisher"

namespace :publishing_api do
  desc "Publish special routes (eg /government)"
  task publish_special_routes: :environment do
    publisher = GdsApi::PublishingApi::SpecialRoutePublisher.new(
      logger: Logger.new(STDOUT),
      publishing_api: Services.publishing_api
    )

    [
      {
        base_path: "/government",
        content_id: "4672b1ff-f147-4d49-a5f4-4959588da5a8",
        title: "Government prefix",
        description: "The prefix route under which almost all government content is published.",
      },
      {
        base_path: "/government/feed",
        content_id: "725a346f-9e5b-486d-873d-2b050c126e09",
        title: "Government feed",
        description: "This route serves the feed of published content",
        rendering_app: Whitehall::RenderingApp::COLLECTIONS_FRONTEND,
      },
      {
        base_path: "/courts-tribunals",
        content_id: "f990c58c-687a-4baf-b1a0-ec2d02c4d654",
        title: "Courts and tribunals",
        description: "The prefix route under which pages for courts and tribunals are published.",
      },
    ].each do |route|
      publisher.publish(
        {
          format: "special_route",
          publishing_app: "whitehall",
          rendering_app: Whitehall::RenderingApp::WHITEHALL_FRONTEND,
          update_type: "major",
          type: "prefix",
          public_updated_at: Time.zone.now.iso8601,
        }.merge(route)
      )
    end
  end

  desc "Send published item links to Publishing API."
  task patch_published_item_links: :environment do
    editions = Edition.published
    count = editions.count
    puts "# Sending #{count} published editions to Publishing API"

    editions.pluck(:id).each_with_index do |item_id, i|
      PublishingApiLinksWorker.perform_async(item_id)

      puts "Queuing #{i}-#{i + 99} of #{count} items" if (i % 100).zero?
    end

    puts "Finished queuing items for Publishing API"
  end

  desc "Send withdrawn item links to Publishing API."
  task patch_withdrawn_item_links: :environment do
    editions = Edition.withdrawn
    count = editions.count
    puts "# Sending #{count} withdrawn editions to Publishing API"

    editions.pluck(:id).each_with_index do |item_id, i|
      PublishingApiLinksWorker.perform_async(item_id)

      puts "Queuing #{i}-#{i + 99} of #{count} items" if (i % 100).zero?
    end

    puts "Finished queuing items for Publishing API"
  end

  desc "Send publishable item links of a specific type to Publishing API (ie, 'CaseStudy')."
  task :publishing_api_patch_links_by_type, [:document_type] => :environment do |_, args|
    document_type = args[:document_type]
    editions = document_type.constantize.published
    count = editions.count
    puts "# Sending #{count} published editions to Publishing API"

    editions.pluck(:id).each_with_index do |item_id, i|
      PublishingApiLinksWorker.perform_async(item_id)

      puts "Queuing #{i}-#{i + 99} of #{count} items" if (i % 100).zero?
    end

    puts "Finished queuing items for Publishing API"
  end
end
