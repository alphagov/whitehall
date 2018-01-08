category_changes = [
  ["housing/local-councils", "housing-local-services/local-councils"],
  ["housing/recycling-rubbish", "housing-local-services/recycling-rubbish"],
  ["housing/safety-environment", "housing-local-services/safety-environment"],
  ["housing/council-tax", "housing-local-services/council-tax"],
]

category_changes.each do |old_category, new_category|
  puts "updating #{old_category} to #{new_category}"

  MainstreamCategory.where(parent_tag: old_category).each do |category|
    puts "\t Category is #{category.title}"
    category.update_attribute(:parent_tag, new_category)
  end
end
