dft = Organisation.find_by!(slug: "department-for-transport")

editions = Edition.published.where(alternative_format_provider_id: dft)
document_ids = editions.pluck(:document_id).uniq

document_ids.each do |id|
  PublishingApiDocumentRepublishingWorker.perform_async_in_queue("bulk_republishing", id)
  print "."
end
