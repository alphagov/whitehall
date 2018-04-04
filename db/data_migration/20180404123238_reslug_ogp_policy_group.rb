old_slug = "government-property-unit-gpu"
new_slug = "office-of-government-property-ogp"

group = PolicyGroup.find_by!(slug: old_slug)

Whitehall::SearchIndex.delete(group)

group.update_attributes!(slug: new_slug)

Whitehall::PublishingApi.republish_async(group)
Whitehall::SearchIndex.add(group)
