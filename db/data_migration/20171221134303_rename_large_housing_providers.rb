old_slug = "letter-from-julian-ashby-to-chairs-and-chief-executives-of-large-housing-providers"
new_slug = "letter-from-julian-ashby-to-chairs-and-chief-executives-of-social-housing-providers"

document = Document.find_by!(slug: old_slug)
edition = document.editions.published.last

Whitehall::SearchIndex.delete(edition)

document.update_attributes!(slug: new_slug)
PublishingApiDocumentRepublishingWorker.new.perform(document.id)

puts "#{old_slug} -> #{new_slug}"
