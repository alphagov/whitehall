slugs = %w(
  vosa-directing-board
  vosa-business-performance-board
  vosa-investment-and-change-board
)

redirect_path = "/government/organisations/vehicle-and-operator-services-agency/about/our-governance"

slugs.each do |slug|
  group = PolicyGroup.find_by(slug: slug)
  next unless group

  content_id = group.content_id

  group.delete
  PublishingApiRedirectWorker.new.perform(content_id, redirect_path, "en")

  puts "#{slug} -> #{redirect_path}"
end
