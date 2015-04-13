namespace :publishing_api do
  desc "export all whitehall content to draft environment of publishing api"
  task :populate_draft_environment => :environment do
    Whitehall::PublishingApi::DraftEnvironmentPopulator.new(logger: Logger.new(STDOUT)).call
  end
end
