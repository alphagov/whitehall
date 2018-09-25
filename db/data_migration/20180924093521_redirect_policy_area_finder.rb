puts "Unpublishing /government/topics and redirecting to /"
Services.publishing_api.unpublish(
  "cdf678f7-d56d-4ea0-bdcc-054bdad4d2d2",
  type: "redirect",
  alternative_path: "/",
)
