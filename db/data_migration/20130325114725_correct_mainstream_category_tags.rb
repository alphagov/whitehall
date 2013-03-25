MainstreamCategory.where(parent_tag: 'citizenship/internationial-funding').each do |category|
  puts "Updating parent tag on category '#{category.title}'"
  category.update_attributes(parent_tag: 'citizenship/international-development')
end
