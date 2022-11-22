require "gds_api/publishing_api/special_route_publisher"

desc "Redirect International Delegation news pages to their non-news page"
task temp_redirect_international_delegation: :environment do
  WorldLocation.international_delegation.each do |world_location|
    Services.publishing_api.unpublish(
      world_location.world_location_news.content_id,
      type: "redirect",
      locale: "en", # none of these pages currently have translations, so we don't need to worry about that here
      alternative_path: "/world/#{world_location.slug}",
    )
  end
end
