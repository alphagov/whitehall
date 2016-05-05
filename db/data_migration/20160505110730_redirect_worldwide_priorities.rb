OLD_PATH = "/government/priority"

#as defined in https://docs.google.com/spreadsheets/d/1N3tvPceqG_7ASE9cET_lbQRdJevW_9h-UDtov_-uRlM/edit#gid=0
SLUGS = [
  ["supporting-uk-business-to-develop-opportunities-in-the-eastern-caribbean","/government/world/barbados"],
  ["uk-and-caribbean-collaboration-on-security-issues","/government/world/barbados"],
  ["promoting-human-rights-issues-in-the-eastern-caribbean","/government/world/barbados"]
  ["supporting-british-nationals-in-barbados-and-the-eastern-caribbean","/government/world/organisations/british-high-commission-barbados"]
  ["strengthening-peace-security-and-democracy-in-ethiopia-somaliland-and-djibouti","/government/world/ethiopia"]
  ["protecting-the-uk-against-drug-trafficking-and-organised-crime-in-west-africa","/government/world/senegal"]
  ["supporting-british-nationals-in-the-dominican-republic-and-haiti","/government/world/organisations/british-embassy-santo-domingo"]
  ["increasing-business-with-the-dominican-republic-and-haiti","/government/world/dominican-republic"]
  ["promoting-strong-relations-between-the-uk-and-the-republic-of-haiti","/government/world/haiti"]
  ["improving-business-with-guyana-and-suriname","/government/world/guyana"]
  ["uk-science-and-innovation-network-gulf","/government/world/qatar"]
  ["chadian-presiden-at-londons-illegal-wildlife-trade-conference","/government/news/decisive-action-agreed-on-illegal-wildlife-trade"]
  ["chadian-presiden-at-londons-illegal-wildlife-trade-conference--2","/government/news/decisive-action-agreed-on-illegal-wildlife-trade"]
  ["supporting-british-nationals-in-the-usa","/government/world/usa"]
  ["developing-good-governance-in-the-turks-and-caicos-islands","/government/world/turks-and-caicos-islands"]
  ["supporting-development-in-pakistan--2","/government/world/organisations/dfid-pakistan"]
  ["supporting-drc-development-with-the-department-for-international-development","/government/world/organisations/dfid-drc"]
  ["supporting-conflict-resolution-in-guinea-bissau","/government/world/guinea-bissau"]
  ["working-with-south-africa-to-promote-and-build-our-people-to-people-partnerships","/government/world/south-africa"]
  ["supporting-development-in-belize","/government/world/belize"]
]

SLUGS.each do |slug|
  old_base_path = OLD_PATH + "/" + slug[0]
  new_base_path = slug[1]
  redirects = [{ path: old_base_path, destination: new_base_path, type: "exact" }]
  PublishingApiRedirectWorker.perform_async(old_base_path, redirects, I18n.default_locale.to_s)
end
