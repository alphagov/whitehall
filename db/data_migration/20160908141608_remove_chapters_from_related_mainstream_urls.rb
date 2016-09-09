#This script removes the last part of a slug for related mainstream content urls that are linking to a chapter of a related mainstream content instead of the related mainstream document.
def detailed_guide?(url)
  p url if url.start_with?("https://www.gov.uk/guidance/")
  url.start_with?("https://www.gov.uk/guidance/")
end

related_mainstream_content_urls = DetailedGuide.select(
                                    :id,
                                    :related_mainstream_content_url
                                  ).where([
                                    "related_mainstream_content_url IS NOT NULL
                                    AND related_mainstream_content_url != ''"
                                  ])

related_mainstream_content_urls.each do |detailed_guide|
  p detailed_guide[:id]
  p detailed_guide[:related_mainstream_content_url]
  next if detailed_guide?(detailed_guide[:related_mainstream_content_url])
  clean_url = detailed_guide[:related_mainstream_content_url][/(https:\/\/www.gov.uk\/)(.*)\//]
  if !clean_url.nil?
    clean_url = clean_url.chop if clean_url[-1] == "/"
    base_path = clean_url[18..-1]
    content_id = Whitehall.publishing_api_v2_client.lookup_content_id(base_path: base_path)
    if content_id.nil?
      File.open("content_items_not_found", "a+")
    detailed_guide_to_update = DetailedGuide.find(detailed_guide[:id])
    detailed_guide_to_update.update_attribute(:related_mainstream_content_url, clean_url)
    p detailed_guide_to_update.related_mainstream_content_url
  end
end


additional_related_mainstream_content_urls = DetailedGuide.select(
                                    :id,
                                    :additional_related_mainstream_content_url
                                  ).where([
                                    "additional_related_mainstream_content_url IS NOT NULL
                                    AND additional_related_mainstream_content_url != ''"
                                  ])

additional_related_mainstream_content_urls.each do |detailed_guide|
  p detailed_guide[:id]
  p detailed_guide[:additional_related_mainstream_content_url]
  next if detailed_guide?(detailed_guide[:additional_related_mainstream_content_url])
  clean_url = detailed_guide[:additional_related_mainstream_content_url][/(https:\/\/www.gov.uk\/)(.*)\//]
  if !clean_url.nil?
    clean_url = clean_url.chop if clean_url[-1] == "/"
    detailed_guide_to_update = DetailedGuide.find(detailed_guide[:id])
    detailed_guide_to_update.update_attribute(:additional_related_mainstream_content_url, clean_url)
    p detailed_guide_to_update.additional_related_mainstream_content_url
  end
end
