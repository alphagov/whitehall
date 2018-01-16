PUBLISHED_AND_PUBLISHABLE_STATES = %w(published draft archived submitted rejected scheduled).freeze

correspondence_scope = Publication.
  where(state: PUBLISHED_AND_PUBLISHABLE_STATES).
  where(publication_type_id: PublicationType::Correspondence.id)

count = correspondence_scope.count
index = 0
reclassified_count = 0

puts "Checking the political status of #{count} correspondence"

correspondence_scope.find_each do |edition|
  if PoliticalContentIdentifier.political?(edition) && !edition.political?
    edition.update_column(:political, true)
    reclassified_count += 1
  end

  index += 1

  puts "Processed #{index} of #{count} correspondence (#{sprintf '%.2f', (index.to_f / count.to_f) * 100}%)" if (index % 1000).zero?
end

puts "Re-classification complete. #{reclassified_count} correspondence out of #{count} re-classified as political"
