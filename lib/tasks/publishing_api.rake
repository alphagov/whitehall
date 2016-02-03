require "gds_api/publishing_api/special_route_publisher"

namespace :publishing_api do
  namespace :republish do
    desc "republish non-edition content to the Publishing API (model_class_name example: TakePartPage)"
    task :non_editions, [:model_class_name] => :environment do |t, args|
      model = args[:model_class_name].constantize
      model.all.find_each do |instance|
        Whitehall::PublishingApi.republish_async(instance)
        print "."
      end
    end

    desc "generate content ids for non-edition content prior to publishing"
    task :add_content_ids, [:model_class_name] => :environment do |t, args|
      model = args[:model_class_name].constantize
      model.all.find_each do |instance|
        instance.update_column(:content_id, SecureRandom.uuid) unless instance.content_id
        print "."
      end
    end
  end

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
        rendering_app: "whitehall-frontend",
        update_type: "major",
        type: "prefix",
        public_updated_at: Time.zone.now.iso8601,
      ))
    end
  end
end

desc "Temporary alias of publishing_api:publish_special_routes for backward compatibility"
task "router:register" => "publishing_api:publish_special_routes"
