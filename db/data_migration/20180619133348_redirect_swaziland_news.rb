puts "Unpublishing /world/swaziland/news and redirecting to /world/eswatini/news"
Services.publishing_api.unpublish(
  "a1a1d345-eae7-4995-8ec2-c7194042fe41",
  type: "redirect",
  alternative_path: "/world/eswatini/news",
)
