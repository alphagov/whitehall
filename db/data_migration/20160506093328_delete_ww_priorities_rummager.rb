BASE_PATH_ROOT = "/government/priority"

SLUGS = [
  "supporting-uk-business-to-develop-opportunities-in-the-eastern-caribbean",
  "uk-and-caribbean-collaboration-on-security-issues",
  "promoting-human-rights-issues-in-the-eastern-caribbean",
  "supporting-british-nationals-in-barbados-and-the-eastern-caribbean",
  "strengthening-peace-security-and-democracy-in-ethiopia-somaliland-and-djibouti",
  "protecting-the-uk-against-drug-trafficking-and-organised-crime-in-west-africa",
  "supporting-british-nationals-in-the-dominican-republic-and-haiti",
  "increasing-business-with-the-dominican-republic-and-haiti",
  "promoting-strong-relations-between-the-uk-and-the-republic-of-haiti",
  "improving-business-with-guyana-and-suriname",
  "uk-science-and-innovation-network-gulf",
  "chadian-presiden-at-londons-illegal-wildlife-trade-conference",
  "chadian-presiden-at-londons-illegal-wildlife-trade-conference--2",
  "supporting-british-nationals-in-the-usa",
  "developing-good-governance-in-the-turks-and-caicos-islands",
  "supporting-development-in-pakistan--2",
  "supporting-drc-development-with-the-department-for-international-development",
  "supporting-conflict-resolution-in-guinea-bissau",
  "working-with-south-africa-to-promote-and-build-our-people-to-people-partnerships",
  "supporting-development-in-belize",
]

SLUGS.each do |slug|
  base_path = BASE_PATH_ROOT + "/" + slug
  Whitehall.government_search_client.delete_content! base_path
end
