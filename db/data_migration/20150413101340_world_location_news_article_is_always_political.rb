index = 0

PUBLISHED_AND_PUBLISHABLE_STATES = %w(published draft archived submitted rejected scheduled)
edition_scope = Edition.where(state: PUBLISHED_AND_PUBLISHABLE_STATES, type: WorldLocationNewsArticle)
edition_count = edition_scope.count

edition_scope.find_each do |edition|
  edition.update_column(:political, true)
  index += 1

  puts "Processed #{index} of #{edition_count} editions (#{(index.to_f / edition_count.to_f) * 100}%)" if index % 1000 == 0
end
