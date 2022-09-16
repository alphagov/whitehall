edition = Edition.find(1_074_361)
html_attachment = HtmlAttachment.find(4_268_087)
html_attachment.update!(slug: "esa-work-capability-assessments-mandatory-reconsiderations-and-appeals-june-2020")
Whitehall::SearchIndex.delete(edition)
Whitehall::PublishingApi.republish_async(html_attachment)
Whitehall::PublishingApi.republish_document_async(edition)
Whitehall::SearchIndex.add(edition)

base_path = "/government/publications/esa-outcomes-of-work-capability-assessments-including-mandatory-reconsiderations-and-appeals-june-2020/esa-work-capability-assessments-mandatory-reconsiderations-and-appeals-march-2020"
destination = "/government/publications/esa-outcomes-of-work-capability-assessments-including-mandatory-reconsiderations-and-appeals-june-2020/esa-work-capability-assessments-mandatory-reconsiderations-and-appeals-june-2020"
redirects = [
  { path: base_path, type: "exact", destination: },
]
redirect = Whitehall::PublishingApi::Redirect.new(base_path, redirects)
content_id = SecureRandom.uuid
puts "Redirecting: #{base_path} to #{destination} with a randomly generated content_id: #{content_id}"
Services.publishing_api.put_content(content_id, redirect.as_json)
puts "Publishing content_id: #{content_id} with redirect #{redirect.as_json}"
Services.publishing_api.publish(content_id, nil, locale: "en")
