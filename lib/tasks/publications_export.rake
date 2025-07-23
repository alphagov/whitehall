namespace :publications do
  desc "Export all publications for a document collection to a CSV file."
  task export_for_document_collection: :environment do
    require "csv"

    filepath = Rails.root.join("publictions_export.csv")
    puts "Exporting publications to #{filepath}..."

    CSV.open(filepath, 'w') do |csv|
      publlication = Publication.first
      csv << %w"title summary body"
      csv << [publlication.title, publlication.summary, publlication.body] if publlication
    end
  end
end