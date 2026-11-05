topical_event_link_ids = OffsiteLinkParent.where(parent_type: %w[TopicalEvent Edition]).distinct.pluck(:offsite_link_id)
other_link_ids = OffsiteLinkParent.where.not(parent_type: %w[TopicalEvent Edition]).distinct.pluck(:offsite_link_id)

offsite_links = OffsiteLink.where(id: topical_event_link_ids - other_link_ids).where.not(date: nil)

puts "Clearing the date on #{offsite_links.count} topical event offsite links"

offsite_links.update_all(date: nil)
