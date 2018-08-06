edition = Edition.find(866063)
document = Document.find(362647)
Whitehall::PublishingApi.republish_document_async(document)
Whitehall::SearchIndex.add(edition)

base_path = "/government/consultations/call-for-evidence-to-identify-uk-interest-in-existing-eu-trade-remedy-measures/test"
destination = "/government/consultations/call-for-evidence-to-identify-uk-interest-in-existing-eu-trade-remedy-measures/provisional-findings-of-the-call-for-evidence-into-UK-interest-in-existing-EU-trade-remedy-measures"
redirects = [
    { path: base_path, type: "exact", destination: destination }
]
redirect = Whitehall::PublishingApi::Redirect.new(base_path, redirects)
content_id = SecureRandom.uuid

puts "Redirecting: #{base_path} to #{destination} with a randomly generated content_id: #{content_id}"

Services.publishing_api.put_content(content_id, redirect.as_json)

puts "Publishing content_id: #{content_id} with redirect #{redirect.as_json}"
Services.publishing_api.publish(content_id, nil, locale: "en")
