require "csv"

csv_file = File.join(File.dirname(__FILE__), "20150724130057_redirect_some_withdrawn_worldwide_priorities.csv")

csv = CSV.parse(File.open(csv_file), headers: true)

puts "Trying to redirect #{csv.size} worldwide priorities"

csv.each do |row|
  slug = row["slug"]

  public_uri = Plek.new.website_uri
  public_uri.path = row["path_for_alternative_url"]
  alternative_url = public_uri.to_s

  wp = WorldwidePriority.published_as(slug, I18n.locale)

  if wp && wp.unpublishing
    puts "Redirecting #{slug} to #{alternative_url}"
    unpublishing = wp.unpublishing

    unpublishing.redirect = true
    unpublishing.alternative_url = alternative_url
    unpublishing.unpublishing_reason_id = UnpublishingReason::Consolidated.id
    unpublishing.explanation = nil
    unpublishing.save!

    wp.update_attribute(:state, "draft")
  else
    puts "No unpublished worldwide priority found for slug #{slug}"
  end
end
