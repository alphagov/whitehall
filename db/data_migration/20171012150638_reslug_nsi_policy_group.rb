old_slug = "nsi-government-payments-service"
new_slug = "nsi-government-payment-services"

group = PolicyGroup.find_by!(slug: old_slug)

Whitehall::SearchIndex.delete(group)

group.update_attributes!(slug: new_slug)

Whitehall::PublishingApi.republish_async(group)
Whitehall::SearchIndex.add(group)
