require "gds_api/publishing_api/special_route_publisher"

namespace :publishing_api do
  namespace :draft do
    namespace :populate do
      desc "export all whitehall content to draft environment of publishing api"
      task :all => :environment do
        Whitehall::PublishingApi::DraftEnvironmentPopulator.new(logger: Logger.new(STDOUT)).call
      end

      desc "export Case studies to draft environment of publishing api"
      task :case_studies => :environment do
        Whitehall::PublishingApi::DraftEnvironmentPopulator.new(items: CaseStudy.latest_edition.find_each, logger: Logger.new(STDOUT)).call
      end
    end
  end

  namespace :live do
    namespace :populate do
      desc "export all published whitehall content to live environment of publishing api"
      task :all => :environment do
        Whitehall::PublishingApi::LiveEnvironmentPopulator.new(logger: Logger.new(STDOUT)).call
      end

      task :case_studies => :environment do
        Whitehall::PublishingApi::LiveEnvironmentPopulator.new(items: CaseStudy.latest_published_edition.find_each, logger: Logger.new(STDOUT)).call
      end
    end
  end

  desc "Publish special routes (eg /government)"
  task publish_special_routes: :environment do
    publisher = GdsApi::PublishingApi::SpecialRoutePublisher.new(logger: Logger.new(STDOUT))

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
