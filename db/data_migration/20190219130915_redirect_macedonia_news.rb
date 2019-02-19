puts "Unpublishing /world/macedonia/news and redirecting to /world/north-macedonia/news"
Services.publishing_api.unpublish(
  "52434a45-7d30-4e4e-8190-c8d963901bef",
  type: "redirect",
  alternative_path: "/world/north-macedonia/news",
)
