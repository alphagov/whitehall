namespace :db do
  desc "Mark all documents of a given organisations as political"
  task mark_as_political: [:organisation_slug] => :environment do |args|
    begin
      puts "Marking documents as political..."
      organisation = find_organisation(args[:organisation_slug])
      mark_editions_as_political(organisation)
      bulk_republish_documents(organisation)
      puts "Marked documents as political."
    rescue => e
      puts "An error occurred: #{e.message}"
    end
  end

  def find_organisation(slug)
    Organisation.find_by!(slug: slug)
  end

  def mark_editions_as_political(organisation)
    editions = organisation.editions
    editions.published.update_all(political: true)
    editions.in_pre_publication_state.update_all(political: true)
  end

  def bulk_republish_documents(organisation)
    organisation.editions.published.map(&:document_id).each do |document_id|
      PublishingApiDocumentRepublishingWorker.perform_async_in_queue("bulk_republishing", document_id, true)
    end
  end
end