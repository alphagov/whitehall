[
  ['driving/businesses', 'Driving and transport businesses', 'Traffic and road management'],
  ['driving/businesses', 'Driving and transport businesses', 'Traffic regulations and safety'],
  ['housing/safety-environment', 'Safety and the environment in your community', 'Land use and management'],
  ['driving/vehicle-safety', 'Vehicle and boat safety', 'Manufacturing schemes and standards'],
  ['business/food', 'Food, catering and retail', 'Food production and safety']
].each do |row|
  parent_tag, parent_title, title = row
  category = MainstreamCategory.create(
    title: title,
    slug: title.parameterize,
    parent_tag: parent_tag,
    parent_title: parent_title
  )
  if category
    puts "Mainstream category #{category.title} created"
  end
end
