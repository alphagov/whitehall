count = 0
Organisation.find_each do |org|
  new_slug = org.name.parameterize
  if new_slug != org.slug
    count += 1
    org.update_attribute :slug, new_slug
  end
end
puts "Updated #{count} organisations"
