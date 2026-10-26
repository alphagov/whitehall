# Before September 2023, unpublishing an edition sent it back to draft and attached an Unpublishing to it.
# 20230927101500_migrate_unpublished_draft_editions_to_unpublished_state moved those editions into the new
# "unpublished" state, but it only selected draft editions. Editions that had been submitted (and sometimes
# rejected) under the old workflow kept their state, so Whitehall treats their documents as never published,
# even though they are unpublished on GOV.UK.
#
# This completes the 2023 migration for those editions. Most become "unpublished", except:
#   - An edition whose Unpublishing is a withdrawal becomes "withdrawn", matching what GOV.UK shows.
#   - An edition whose document already has a newer unpublished edition becomes "superseded", so that
#     the document keeps a single unpublished edition.

editions = Edition
  .joins(:unpublishing)
  .where(state: %w[rejected submitted])
  .includes(:unpublishing, :document)
  .to_a

puts "Found #{editions.count} submitted or rejected editions with an Unpublishing"

document_ids_to_republish = []

editions.each do |edition|
  document = edition.document

  new_state =
    if edition.unpublishing.unpublishing_reason_id == UnpublishingReason::WITHDRAWN_ID
      "withdrawn"
    elsif document.editions.unpublished.where("editions.id > ?", edition.id).exists?
      "superseded"
    else
      "unpublished"
    end

  puts "Document #{document.id}: Changing #{edition.state} edition #{edition.id} to #{new_state}"
  edition.update_column(:state, new_state)
  document.update_edition_references
  document_ids_to_republish << document.id
end

remaining_count = Edition.joins(:unpublishing).where(state: %w[rejected submitted]).count
puts "\nRemaining submitted or rejected editions with an Unpublishing: #{remaining_count}"

# Wait for the migration's transaction to commit, so the jobs don't read the old state.
ActiveRecord.after_all_transactions_commit do
  document_ids_to_republish.each do |document_id|
    PublishingApiDocumentRepublishingJob.perform_async(document_id, true)
  end
  puts "Queued #{document_ids_to_republish.count} documents for republishing"
end
