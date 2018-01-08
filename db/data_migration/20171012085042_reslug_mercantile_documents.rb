slugs = %w(
  take-a-business-dispute-to-the-mercantile-court
  mercantile-court-judges-and-clerks
  london-mercantile-court-hearing-and-trial-dates
)

slugs.each do |slug|
  document = Document.find_by!(slug: slug)
  edition = document.editions.published.last

  Whitehall::SearchIndex.delete(edition)

  new_slug = slug.gsub("mercantile", "commercial-circuit")
  document.update_attributes!(slug: new_slug)

  queue = "bulk_republishing"
  id = document.id
  PublishingApiDocumentRepublishingWorker.perform_async_in_queue(queue, id)

  puts "#{slug} -> #{new_slug}"
end
