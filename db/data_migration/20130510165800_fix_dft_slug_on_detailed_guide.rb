old_doc = Document.find(139244)
puts "updating #{old_doc.slug} to deleted-becoming-a-privately-owned-test-facility"
old_doc.update_column(:slug, "deleted-becoming-a-privately-owned-test-facility")
document = Document.find(142538)

Searchable::Delete.later(document.latest_edition)

puts "updating #{document.slug} to becoming-a-privately-owned-test-facility"
document.update_column(:slug, "becoming-a-privately-owned-test-facility")
document.reload

Searchable::Index.later(document.latest_edition)