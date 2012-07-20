require 'logger'

namespace :guidance do
  task :import_csv, [:file] => [:environment] do |t, args|
    CSV.foreach(args[:file], {:headers => true}) do |row|
      puts row
    end
  end

  desc "Upload CSVs of Specialist Guidance content to the database"
end