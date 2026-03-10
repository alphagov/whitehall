worldwide_orgs_with_corrupted_default_news_images = WorldwideOrganisation.where
  .not(state: "superseded")
  .select { |wwo| wwo.default_news_image && wwo.default_news_image.assets.count.zero? }

worldwide_orgs_with_corrupted_default_news_images.each do |wwo|
  puts "Clearing default_news_image '#{wwo.default_news_image.carrierwave_image}' of Worldwide Organisation with ID #{wwo.id}"
  wwo.default_news_image.destroy!
end
