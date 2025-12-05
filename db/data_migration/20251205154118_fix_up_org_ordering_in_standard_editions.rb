start_datetime = Time.parse("2025-11-19 00:00:00 UTC")
end_datetime   = Time.parse("2025-12-05 13:00 UTC")

qualifying_editions = StandardEdition
                        .select("editions.*")
                        .joins(:edition_organisations)
                        .where(state: "published")
                        .where("editions.created_at >= ? AND editions.created_at <= ?", start_datetime, end_datetime)
                        .group("editions.id")
                        .having("COUNT(edition_organisations.edition_id) > 1")

puts "Starting publish operation for Standard Editions..."

qualifying_editions.find_each do |edition|
  Whitehall::PublishingApi.publish(model_instance: edition, bulk_publishing: true)
end

puts "Publish operation complete. Processed #{qualifying_editions.size} editions."
