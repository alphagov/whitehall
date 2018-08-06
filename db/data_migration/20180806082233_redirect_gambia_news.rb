puts "Unpublishing /world/gambia/news and redirecting to /world/the-gambia/news"
Services.publishing_api.unpublish(
  "3f8c93e2-5da5-4ba8-80ad-e10b0cc5a754",
  type: "redirect",
  alternative_path: "/world/the-gambia/news",
)
