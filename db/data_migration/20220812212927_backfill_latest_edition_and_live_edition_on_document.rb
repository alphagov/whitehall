# Populate latest_edition_id and live_edition_id for documents that don't have them defined
all_documents = Document.where(latest_edition_id: nil, live_edition_id: nil)
total = all_documents.count

@logger.info "There are #{total} documents to populate"

done = 0
all_documents.find_in_batches do |documents|
  documents.each(&:update_edition_references)
  done += documents.count
  @logger.info "Done #{done}/#{total} (#{((done / total.to_f) * 100).to_i}%)"
end
