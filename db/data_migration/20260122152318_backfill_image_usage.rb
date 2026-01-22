govspeak_embed_image_count = Image.joins(:edition).where.not(editions: { type: "LandingPage" }).update_all(usage: "govspeak_embed")

puts "Set usage for #{govspeak_embed_image_count} govspeak embedding images"

landing_page_images = Image.joins(:edition).where(editions: { type: "LandingPage" })
landing_page_images.each do |image|
  image_kind = Whitehall.image_kinds.fetch(image.image_kind)
  image.update!(usage: image_kind.permitted_uses.first)
end

puts "Set usage for #{landing_page_images.size} landing page images"
