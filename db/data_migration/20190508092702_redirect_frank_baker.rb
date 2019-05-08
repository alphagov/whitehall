puts "Unpublishing /government/people/frank-baker and redirecting to /government/people/frank-baker--2"
Services.publishing_api.unpublish(
  "85330009-c0f1-11e4-8223-005056011aef",
  type: "redirect",
  alternative_path: "/government/people/frank-baker--2",
)
