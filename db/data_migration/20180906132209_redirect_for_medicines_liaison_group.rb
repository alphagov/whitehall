old_slug = "medicines-advertising-liaison-group"
new_slug = "medicines-devices-advertising-liaison-group"

group = PolicyGroup.find_by!(slug: old_slug)

Whitehall::SearchIndex.delete(group)

group.update_attributes!(slug: new_slug)

Whitehall::SearchIndex.add(group)
