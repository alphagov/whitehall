desc "override email notifications for a document collection to a given taxonomy topic, can only be run on against a document that has never been published."
task :set_taxonomy_topic_email_override, %i[document_collection_id taxon_content_id confirmation_string] => :environment do |_, args|
  document_collection_id = args[:document_collection_id]
  taxon_content_id = args[:taxon_content_id]
  confirmation_string = args[:confirmation_string]

  if document_collection_id.blank? || taxon_content_id.blank?
    raise "Document collection ID and taxon content ID are required arguments"
  end

  document_collection = DocumentCollection.find_by(id: document_collection_id)
  raise "Cannot find document collection with ID: #{document_collection_id}" unless document_collection

  raise "Cannot set a taxonomy topic email override on previously published documents" if document_collection.document.live?

  taxon_content_item = Services.publishing_api.get_content(taxon_content_id)
  sub_message = "#{taxon_content_item.to_h['title']} for document collection #{document_collection.id}, #{document_collection.title}."

  if confirmation_string == "run_for_real"
    document_collection.update!(taxonomy_topic_email_override: taxon_content_id)
    puts "Taxonomy topic email override set to #{sub_message}"
  else
    puts "This was a dry run. Taxonomy topic email override would have been set to #{sub_message}"
  end
end
