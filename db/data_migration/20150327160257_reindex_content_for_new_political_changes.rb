POLITICAL_ORG_SLUGS = %w[
  office-for-disability-issues
  uk-export-finance
]

puts "Setting political flag on the following organisations:"
POLITICAL_ORG_SLUGS.each do |slug|
  organsation = Organisation.find_by(slug: slug)
  puts "\t#{organsation.name}"
  organsation.update_attribute(:political, true)
end

APOLITICAL_ORG_SLUGS = %w[
  standards-and-testing-agency
  third-party-campaigning-review
]

puts "Unsetting political flag on the following organisations:"
APOLITICAL_ORG_SLUGS.each do |slug|
  organsation = Organisation.find_by(slug: slug)
  puts "\t#{organsation.name}"
  organsation.update_attribute(:political, false)
end

index = 0

PUBLISHED_AND_PUBLISHABLE_STATES = %w(published draft archived submitted rejected scheduled)
edition_scope = Edition.where(state: PUBLISHED_AND_PUBLISHABLE_STATES)
edition_count = edition_scope.count

edition_scope.find_each do |edition|
  edition.update_column(:political, PoliticalContentIdentifier.political?(edition))

  index += 1

  puts "Processed #{index} of #{edition_count} editions (#{(index.to_f/edition_count.to_f)*100}%)" if index % 1000 == 0
end
