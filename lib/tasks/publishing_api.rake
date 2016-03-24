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
  task :publishing_api_patch_links, [:item_classes] => :environment do |_, args|
    def patch_links(item)
      retries = 0
      begin
        content_id = item.content_id
        links = PublishingApiPresenters.presenter_for(item).links
        if links && !links.empty?
          Whitehall.publishing_api_v2_client.patch_links(content_id, {links: links})
        end
      rescue GdsApi::TimedOutException, Timeout::Error
        retries += 1
        if retries <= 3
          $stderr.puts "Class #{item.class} id: #{item.id} Timeout: retry #{retries}"
          sleep 0.5
          retry
        end
        raise
      end
    rescue => err
      $stderr.puts "Class: #{item.class}; id: #{item.id}; Error: #{err.message}"
    end

    args[:item_classes].split(',').each do |class_name|
      klass = class_name.constantize
      if klass.ancestors.include?(Edition)
        editions = klass.published
        count = editions.count
        $stdout.puts "# Sending #{count} published #{class_name} items to Publishing API"
      else
        editions = klass.all
        count = editions.count
        $stdout.puts "# Sending all #{count} #{class_name} items to Publishing API"
      end

      editions.find_each.with_index do |publishable_item, i|
        patch_links(publishable_item)

        $stdout.puts "Sending #{i}-#{i + 99} of #{count} items" if i % 100 == 0
      end
      $stdout.puts "Finished sending items to Publishing API"
    end
  end
end

desc "Temporary alias of publishing_api:publish_special_routes for backward compatibility"
task "router:register" => "publishing_api:publish_special_routes"
