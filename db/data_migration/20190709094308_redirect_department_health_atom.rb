base_path = "/government/organisations/department-of-health"
destination = "/government/organisations/department-of-health-and-social-care"
redirects = [
  { path: "#{base_path}.atom", type: "exact", destination: "#{destination}.atom" },
  { path: base_path, type: "exact", destination: },
]
redirect = Whitehall::PublishingApi::Redirect.new(base_path, redirects)
content_id = "b721cee0-b24c-42c0-a8c4-fa215af727eb"

puts "Redirecting: #{base_path} to #{destination} with content_id: #{content_id}"

Services.publishing_api.put_content(content_id, redirect.as_json)

puts "Publishing content_id: #{content_id} with redirect #{redirect.as_json}"
Services.publishing_api.publish(content_id, nil, locale: "en")
