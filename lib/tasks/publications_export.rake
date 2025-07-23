namespace :publications do
  desc "Export all publications for a document collection to a CSV file."
  task export_for_document_collection: :environment do
    require "csv"

    filepath = Rails.root.join("publictions_export.csv")
    puts "Exporting publications to #{filepath}..."

    CSV.open(filepath, 'w') do |csv|
    end
  end
end