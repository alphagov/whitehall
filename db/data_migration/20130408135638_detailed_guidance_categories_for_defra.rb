defra_categories = [
  {
    parent_title: "Businesses and self-employed",
    parent_tag: "business/waste-environment",
    title: "Climate change planning and preparation",
    description: "Includes information for local authorities and infrastructure companies on climate change adaptation"
  },
  {
    parent_title: "Coasts, countryside and creatures",
    parent_tag: "citizenship/coasts-countryside",
    title: "Flooding and coastal change",
    description: "Includes guidance on flood risk management"
  },
  {
    parent_title: "Waste and environmental impact",
    parent_tag: "business/waste-environment",
    title: "Healthcare waste management",
    description: "Includes guidance on disposal of healthcare waste management"
  },
  {
    parent_title: "Recycling, rubbish, streets and roads",
    parent_tag: "housing/recycling-rubbish",
    title: "Beach and street cleanliness",
    description: "Includes litter and fouling, the Total Environment Initiative and the Household Reward and Recognition Scheme"
  },
  {
    parent_title: "Travel abroad",
    parent_tag: "abroad/travel-abroad",
    title: "Pet travel and welfare",
    description: "Includes travelling with assistance dogs, quarantine and animal welfare legislation"
  },
  {
    parent_title: "Coasts, countryside and creatures",
    parent_tag: "citizenship/coasts-countryside",
    title: "Wildlife and habitat conservation",
    description: "Includes biodiversity offsetting, habitat conservation and managing protected areas"
  }
]

defra_categories.each do |row|
  if MainstreamCategory.find_by_title(row[:title])
    puts "Mainstream category '#{row[:title]}' already exists, skipping"
  else
    category = MainstreamCategory.create!(row.merge(slug: row[:title].parameterize))
    puts "Created mainstream category: #{category.id}: '#{category.title}'"
  end
end
