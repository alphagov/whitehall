# These translations were unpublished but the translation was never marked as 'gone' in Publishing API or Content Store
WorldLocation.find_by(slug: "afghanistan").world_location_news.publish_gone_translation_to_publishing_api(:dr)
WorldLocation.find_by(slug: "azerbaijan").world_location_news.publish_gone_translation_to_publishing_api(:az)
WorldLocation.find_by(slug: "portugal").world_location_news.publish_gone_translation_to_publishing_api(:pt)

# These documents were unpublished but there is no associated unpublishing record in the Whitehall database, nor did the unpublishing request make it through to Publishing API or Content Store
slugs = %w[
  cumbre-de-las-ninas-2014
  department-of-healths-staff-survey-results-2013
  local-authority-carbon-dioxide-emissions-methodology-notes
  national-curriculum-review
  uk-greenhouse-gas-emissions
]
Document.where(slug: slugs).pluck(:content_id).each do |content_id|
  PublishingApiGoneWorker.new.perform(content_id, nil, nil, :en)
end
