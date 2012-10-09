require "csv"

namespace :db do
  namespace :data do
    desc "Run all data migrations"
    task :migrate => :environment do
      Whitehall::DataMigrator.new.run
    end
  end
end
