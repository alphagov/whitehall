publishing_bot = User.find_by!(name: "Scheduled Publishing Robot", uid: nil)
body = "The URL was changed to remove capital letters and underscores, so that it meets the GOV.UK URL rules. The old URL redirects to the new one."

version_ids = (9_167_585..9_167_640).to_a

versions = Version.where(
  id: version_ids,
  item_type: "Edition",
  event: "update",
  whodunnit: [nil, publishing_bot],
  created_at: Time.zone.parse("2026-08-13 12:06")..Time.zone.parse("2026-08-13 12:09"),
)

puts "Found #{versions.count} of #{version_ids.count} versions"

versions.find_each do |version|
  Version.transaction do
    version.update!(user: publishing_bot)
    EditorialRemark.find_or_create_by!(edition_id: version.item_id, author: publishing_bot, body:) do |remark|
      remark.created_at = version.created_at
      remark.updated_at = version.created_at
    end
  end
  puts "Attributed version #{version.id} for edition #{version.item_id}"
end
