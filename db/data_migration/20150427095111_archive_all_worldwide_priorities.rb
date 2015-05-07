reason = "This information has been archived. See [what the UK government is doing around the world](https://www.gov.uk/government/world)."

WorldwidePriority.where(state: "published").each do |wp|
  edition = wp.latest_edition
  puts "Archiving #{edition.title} - edition #{edition.id}"
  edition.build_unpublishing(explanation: reason, unpublishing_reason_id: UnpublishingReason::Archived.id)
  archiver = Whitehall.edition_services.archiver(edition)
  unless archiver.perform!
    puts "Could not archive edition (#{edition.id}): #{archiver.failure_reason}"
  end
end
