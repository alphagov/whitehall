#Fix the interested editions and add MOD to them
edition_ids = [421608, 421659, 421662, 421675, 421676, 421679, 423612, 464978]

mod_organisation_id = 17
mod = Organisation.find(mod_organisation_id)

editions = Edition.find(edition_ids).each {|e| e.organisations << mod}
editions.map(&:document_id).each do |document_id|
  PublishingApiDocumentRepublishingWorker.perform_async(document_id)
end
