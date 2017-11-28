old_slug = "digital-academy"
new_slug = "gds-academy"

group = PolicyGroup.find_by!(slug: old_slug)

Whitehall::SearchIndex.delete(group)

group.update_attributes!(slug: new_slug)

Whitehall::PublishingApi.republish_async(group)
Whitehall::SearchIndex.add(group)

puts "#{old_slug} -> #{new_slug}"
