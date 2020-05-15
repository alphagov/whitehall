# Fix the interested editions and add MOD to them
edition_ids = [421_608, 421_659, 421_662, 421_675, 421_676, 421_679, 423_612, 464_978]

mod_organisation_id = 17
mod = Organisation.find(mod_organisation_id)

editions = Edition.find(edition_ids).each { |e| e.organisations << mod }
editions.map(&:document_id).each do |document_id|
  PublishingApiDocumentRepublishingWorker.perform_async(document_id)
end
