old_slug = "social-housing-regulation-regulating-the-standards"
new_slug = "regulating-the-standards"

document = Document.find_by(slug: old_slug)

if document
  # remove the most recent edition from the search index
  edition = document.editions.published.last
  Whitehall::SearchIndex.delete(edition)

  # change the slug of the document
  document.update_attributes!(slug: new_slug)
  PublishingApiDocumentRepublishingWorker.new.perform(document.id)
  puts "Renamed slug: #{old_slug} to #{new_slug}"

  # add a redirect for the old url
  from_path = "/government/publications/#{old_slug}"
  to_path = "/government/publications/#{new_slug}"
  redirects = [
    { path: from_path, type: "exact", destination: to_path }
  ]
  redirect = Whitehall::PublishingApi::Redirect.new(from_path, redirects)
  content_id = SecureRandom.uuid

  puts "Redirecting: #{from_path} to #{to_path} with a randomly generated content_id: #{content_id}"
  Services.publishing_api.put_content(content_id, redirect.as_json)

  puts "Publishing content_id: #{content_id} with redirect #{redirect.as_json}"
  Services.publishing_api.publish(content_id, nil, locale: "en")
end
