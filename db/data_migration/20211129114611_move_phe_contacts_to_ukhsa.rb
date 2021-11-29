phe = Organisation.find_by!(slug: "public-health-england")
ukhsa = Organisation.find_by!(slug: "uk-health-security-agency")

phe.contacts.update_all(contactable_id: ukhsa.id)

Whitehall::PublishingApi.republish_async(phe)
Whitehall::PublishingApi.republish_async(ukhsa)
