old_slug = "industry-sector-oil-and-gas-exploration-and-development"

category = MainstreamCategory.find_by_slug(old_slug)

if category.present?
  category.title = "Oil and gas: Exploration and production"
  category.slug = "industry-sector-oil-and-gas-exploration-and-production"
  category.save!(validate: false)

  puts "Mainstream category '#{old_slug}' renamed to '#{category.slug}'"
else
  puts "Mainstream category '#{old_slug}' does not exist"
end
