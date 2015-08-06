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
end
