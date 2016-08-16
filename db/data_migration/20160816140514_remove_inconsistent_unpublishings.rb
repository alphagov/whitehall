unpublishings = Unpublishing.joins(:edition).where("editions.state like 'published'")

puts "Deleting #{unpublishings.count} unpublishings"

unpublishings.destroy_all

