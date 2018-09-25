puts "Unpublishing /government/policies and redirecting to /"
Services.publishing_api.unpublish(
  "d6582d48-df19-46b3-bf84-9157192801a6",
  type: "redirect",
  alternative_path: "/",
)
