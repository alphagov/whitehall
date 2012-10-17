existing_category = MainstreamCategory.where(title: 'Traffic regulations and safety').first

if existing_category
  existing_category.title = 'Transport regulations and safety'
  existing_category.slug = 'transport-regulations-and-safety'
  existing_category.save!
end
