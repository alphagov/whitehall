BASE_PATH_ROOT = "/government/organisations/"

SLUGS = [
  "national-security/groups/intelligence-and-security-committee",
  "national-security/groups/joint-intelligence-committee",
  "national-security/groups/joint-intelligence-organisation",
  "national-security/groups/national-security-council",
  "civil-service/groups/civil-service-board",
  "cabinet-office/groups/cabinet-office-board"
]

SLUGS.each do |slug|
  base_path = BASE_PATH_ROOT + slug
  begin
    Whitehall.government_search_client.delete_content! base_path
  rescue GdsApi::HTTPNotFound => e
    puts "\n" + "=" * 25 + "\nURL not found error:\n#{e}"
  end
end
