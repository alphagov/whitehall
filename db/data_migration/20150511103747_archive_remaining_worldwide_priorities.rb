reason = "This information has been archived. See [what the UK government is doing around the world](https://www.gov.uk/government/world)."

WorldwidePriority.where(state: "published").each do |edition|
  latest_edition = edition.latest_edition
  deleter = Whitehall.edition_services.deleter(latest_edition)
  puts "Deleting #{latest_edition.title} - edition #{latest_edition.id}"
  unless deleter.perform!
    puts "Could not delete edition (#{latest_edition.id}): #{deleter.failure_reason}"
  end

  puts "Archiving #{edition.title} - edition #{edition.id}"
  edition.build_unpublishing(explanation: reason, unpublishing_reason_id: UnpublishingReason::Withdrawn.id)
  archiver = Whitehall.edition_services.archiver(edition)
  unless archiver.perform!
    puts "Could not archive edition (#{edition.id}): #{archiver.failure_reason}"
  end

  puts "\n\n"
end
