# Before September 2023, unpublishing an edition sent it back to draft and attached an Unpublishing to it.
# 20230927101500_migrate_unpublished_draft_editions_to_unpublished_state moved those editions into the new
# "unpublished" state, but it only selected draft editions. Editions that had been submitted (and sometimes
# rejected) under the old workflow kept their state, so Whitehall treats their documents as never published,
# even though they are unpublished on GOV.UK.
#
# This completes the 2023 migration for those editions, with two exceptions:
#   - An edition whose Unpublishing is a withdrawal is skipped, as making it "withdrawn" would make it live.
#   - An edition whose document already has a newer unpublished edition becomes "superseded" instead, so that
#     the document keeps a single unpublished edition.

editions = Edition
  .joins(:unpublishing)
  .where(state: %w[rejected submitted])
  .includes(:unpublishing, :document)
  .to_a

puts "Found #{editions.count} submitted or rejected editions with an Unpublishing"

editions.each do |edition|
  document = edition.document

  if edition.unpublishing.unpublishing_reason_id == UnpublishingReason::WITHDRAWN_ID
    puts "Document #{document.id}: Skipping edition #{edition.id}, as its Unpublishing is a withdrawal"
    next
  end

  has_newer_unpublished_edition = document.editions.unpublished.where("editions.id > ?", edition.id).exists?
  new_state = has_newer_unpublished_edition ? "superseded" : "unpublished"

  puts "Document #{document.id}: Changing #{edition.state} edition #{edition.id} to #{new_state}"
  edition.update_column(:state, new_state)
  document.update_edition_references

  # Whitehall no longer has a draft for this document, so Publishing API shouldn't either.
  # The job does nothing if there is no draft.
  PublishingApiDiscardDraftJob.perform_async(edition.content_id, edition.primary_locale)
end

remaining_count = Edition.joins(:unpublishing).where(state: %w[rejected submitted]).count
puts "\nRemaining submitted or rejected editions with an Unpublishing: #{remaining_count} (the skipped withdrawals)"
