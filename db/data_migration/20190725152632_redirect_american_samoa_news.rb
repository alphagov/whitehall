american_samoa = WorldLocation.find_by(slug: "american-samoa")
base_path = "/world/american-samoa/news"
destination = "/world/usa/news"

puts "Unpublishing #{base_path} and redirecting to #{destination}"
Services.publishing_api.unpublish(
  american_samoa.news_page_content_id,
  type: "redirect",
  alternative_path: destination,
)
