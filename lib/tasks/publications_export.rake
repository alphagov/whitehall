namespace :publications do
  desc "Export all publications for a document collection to a CSV file."
  task export_for_document_collection: :environment do
    require "csv"

    filepath = Rails.root.join("publications_export.csv")
    puts "Exporting publications to #{filepath}..."

    CSV.open(filepath, 'w') do |csv|
      publication = Publication.first
      csv << %w"title summary body attachment_title attachment_filename attachment_url attachment_created_at attachment_updated_at"
      csv << [
        publication.title,
        publication.summary,
        publication.body,
        publication.attachments[0].title,
        publication.attachments[0].filename,
        publication.attachments[0].url,
        publication.attachments[0].created_at,
        publication.attachments[0].updated_at,
      ] if publication
    end
  end
end