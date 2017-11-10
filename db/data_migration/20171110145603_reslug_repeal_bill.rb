old_slug = "information-about-the-repeal-bill"
new_slug = "information-about-the-withdrawal-bill"

document = Document.find_by!(slug: old_slug)
edition = document.editions.published.last

Whitehall::SearchIndex.delete(edition)

document.update_attributes!(slug: new_slug)
PublishingApiDocumentRepublishingWorker.new.perform(document.id)

puts "#{old_slug} -> #{new_slug}"
