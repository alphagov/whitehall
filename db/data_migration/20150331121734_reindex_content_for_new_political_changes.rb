index = 0

PUBLISHED_AND_PUBLISHABLE_STATES = %w(published draft archived submitted rejected scheduled).freeze
edition_scope = Edition.where(state: PUBLISHED_AND_PUBLISHABLE_STATES)
edition_count = edition_scope.count

edition_scope.find_each do |edition|
  edition.update_column(:political, PoliticalContentIdentifier.political?(edition))

  index += 1

  puts "Processed #{index} of #{edition_count} editions (#{(index.to_f / edition_count.to_f) * 100}%)" if (index % 1000).zero?
end
