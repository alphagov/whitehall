POLITICAL_ORG_SLUGS = %w[
  education-funding-agency
  national-college-for-teaching-and-leadership
]

PUBLISHED_AND_PUBLISHABLE_STATES = %w(published draft archived submitted rejected scheduled)

POLITICAL_ORG_SLUGS.each do |slug|
  organsation = Organisation.find_by(slug: slug)
  puts "Setting political flag for #{organsation.name}"
  organsation.update_attribute(:political, true)

  puts "Updating editions from \t#{organsation.name}"
  index = 0
  edition_scope = organsation.editions.where(state: PUBLISHED_AND_PUBLISHABLE_STATES)
  edition_count = edition_scope.count

  edition_scope.find_each do |edition|
    if PoliticalContentIdentifier.political?(edition)
      edition.update_column(:political, true)
    end

    index += 1

    puts "Processed #{index} of #{edition_count} editions (#{(index.to_f / edition_count.to_f) * 100}%) from #{organsation.name}" if index % 1000 == 0
  end
end
