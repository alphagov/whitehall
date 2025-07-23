namespace :publications do
  desc "Export all publications for a document collection to a CSV file."
  task export_for_document_collection: :environment do
    require "csv"

    filepath = Rails.root.join("publications_export.csv")
    puts "Exporting publications to #{filepath}..."

    CSV.open(filepath, 'w') do |csv|
      publication = Publication.first
      csv << %w"title summary body"
      csv << [publication.title, publication.summary, publication.body] if publication
    end
  end
end