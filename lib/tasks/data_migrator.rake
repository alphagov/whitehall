require "csv"

namespace :db do
  namespace :data do
    desc "Run all data migrations, or a specific version assigned to environment variable VERSION"
    task migrate: :environment do
      Whitehall::DataMigrator.new.run
    end
  end
end
