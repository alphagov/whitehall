namespace :import do
  task :hmcts, [:csv_path] => :environment do |_, args|
    Import::HmctsImporter.new(ENV["DRY_RUN"]).import(args[:csv_path])
  end
end
