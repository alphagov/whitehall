namespace :import do
  task :hmcts, [:csv_path] => :environment do |_, args|
    Import::HmctsImporter.import(args[:csv_path])
  end
end
