unpublishings = Unpublishing.joins(:edition).where(editions: { state: 'published' })

puts "Deleting #{unpublishings.count} unpublishings"

unpublishings.delete_all
