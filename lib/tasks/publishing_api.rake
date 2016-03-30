require "gds_api/publishing_api/special_route_publisher"

namespace :publishing_api do
  desc "Publish special routes (eg /government)"
  task publish_special_routes: :environment do
    publisher = GdsApi::PublishingApi::SpecialRoutePublisher.new(
      logger: Logger.new(STDOUT),
      publishing_api: Whitehall.publishing_api_v2_client
    )

    [
      {
        base_path: "/government",
        content_id: "4672b1ff-f147-4d49-a5f4-4959588da5a8",
        title: "Government prefix",
        description: "The prefix route under which almost all government content is published.",
      },
      {
        base_path: "/courts-tribunals",
        content_id: "f990c58c-687a-4baf-b1a0-ec2d02c4d654",
        title: "Courts and tribunals",
        description: "The prefix route under which pages for courts and tribunals are published.",
      },
    ].each do |route|
      publisher.publish(route.merge(
        format: "special_route",
        publishing_app: "whitehall",
        rendering_app: Whitehall::RenderingApp::WHITEHALL_FRONTEND,
        update_type: "major",
        type: "prefix",
        public_updated_at: Time.zone.now.iso8601,
      ))
    end
  end

  desc "Send publishable item links to Publishing API."
  task publishing_api_patch_links: :environment do
    editions = Edition.published
    count = editions.count
    $stdout.puts "# Sending #{count} published editions to Publishing API"

    editions.pluck(:id).each_with_index do |item_id, i|
      PublishingApiLinksWorker.perform_async(item_id)

      $stdout.puts "Queuing #{i}-#{i + 99} of #{count} items" if i % 100 == 0
    end

    $stdout.puts "Finished queuing items for Publishing API"
  end
end

desc "Temporary alias of publishing_api:publish_special_routes for backward compatibility"
task "router:register" => "publishing_api:publish_special_routes"
