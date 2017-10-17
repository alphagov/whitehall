old_slug = "highways-agency-litter-strategy"
new_slug = "highways-england-litter-strategy"

document = Document.find_by!(slug: old_slug)
edition = document.editions.published.last

Whitehall::SearchIndex.delete(edition)

document.update_attributes!(slug: new_slug)
PublishingApiDocumentRepublishingWorker.new.perform(document.id)

puts "#{old_slug} -> #{new_slug}"
