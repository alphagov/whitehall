desc "Export all publications for a document collection to a CSV file."
task :export_publications_for_document_collection, %i[organisation_slug documents_collection_slug] => :environment do |_, args|
  require "csv"

  filepath = Rails.root.join("/tmp/publications_export.csv")
  puts "Exporting publications to #{filepath}..."

  publications = Publication
                   .joins(document: { document_collections: %i[document organisations] })
                   .where(organisations: { slug: args[:organisation_slug] })
                   .where(documents_editions: { slug: args[:documents_collection_slug] })
                   .where(document_collections_documents: { state: :published })
                   .where(state: :published)

  CSV.open(filepath, "w") do |csv|
    csv << %w[title summary body attachment_title attachment_filename attachment_url attachment_created_at attachment_updated_at]
    publications.each do |publication|
      attachment = publication.attachments.find { |a| a.is_a?(FileAttachment) && a.pdf? }
      csv << [
        publication.title,
        publication.summary,
        publication.body,
        attachment&.title || "",
        attachment&.filename || "",
        attachment&.url || "",
        attachment&.created_at || "",
        attachment&.updated_at || "",
      ]
    end
  end

  puts "Exported #{publications.count} Publication(s)."
end
