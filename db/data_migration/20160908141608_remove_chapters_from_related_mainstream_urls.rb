# This script removes the last part of a slug for related mainstream content urls
# that are linking to a chapter of a related mainstream content instead of the
# related mainstream document.
# The script also fixes some urls that were prefixed with an http instead of an
# https such that they can also be migrated - some of the http prefixed urls
# might have valid base_paths already, in which case we just save the https
# based url. Some of them might also have chapters in which case we remove the
# chapters and save.
# Finally, the scripts outputs any items that need manual updating.

require 'gds-api-adapters'

def validate_url_content_id(url)
  url = url.chomp
  base_path = url[18..-1] if url.length > 17
  content_id = Services.publishing_api.lookup_content_id(base_path: base_path) if base_path
  content_id
end

def detailed_guide?(_id, url)
  url.start_with?("https://www.gov.uk/guidance/")
end

def update_mainstream_url(id, clean_url)
  detailed_guide = DetailedGuide.find(id)
  detailed_guide.update_attribute(:related_mainstream_content_url, clean_url)
end

def update_additional_related_mainstream_url(id, clean_url)
  detailed_guide = DetailedGuide.find(id)
  detailed_guide.update_attribute(:additional_related_mainstream_content_url, clean_url)
end

def clean_the_url(url)
  clean_url = url[/(http(s?):\/\/www.gov.uk\/)([^\/]*)/]
  if !clean_url.nil?
    clean_url.insert(4, 's') if clean_url.start_with?('http://')
    clean_url = clean_url.chop if clean_url[-1] == "/"
  end
  clean_url
end

related_mainstream_content_urls = DetailedGuide
                                    .select(
                                      :id,
                                      :related_mainstream_content_url,
                                    )
                                    .where(
                                      [
                                        "related_mainstream_content_url IS NOT NULL " \
                                        "AND related_mainstream_content_url != '' " \
                                        "AND state != 'superseded'"
                                      ]
                                    )
puts "#{related_mainstream_content_urls.length} Related mainstream content urls"
related_mainstream_content_urls.each do |detailed_guide|
  next if detailed_guide?(detailed_guide[:id], detailed_guide[:related_mainstream_content_url])
  content_id = validate_url_content_id(detailed_guide[:related_mainstream_content_url])
  if content_id.nil?
    chopped_url = clean_the_url(detailed_guide[:related_mainstream_content_url])
    content_id = validate_url_content_id(chopped_url) if chopped_url
    update_mainstream_url(detailed_guide[:id], chopped_url) if !content_id.nil?
  end
  puts "Content item not found: #{detailed_guide[:id]}, #{detailed_guide[:related_mainstream_content_url]}" if content_id.nil?
end

additional_related_mainstream_content_urls = DetailedGuide
                                               .select(
                                                 :id,
                                                 :additional_related_mainstream_content_url
                                               )
                                               .where(
                                                 [
                                                   "additional_related_mainstream_content_url IS NOT NULL " \
                                                   "AND additional_related_mainstream_content_url != ''" \
                                                   "AND state != 'superseded'"
                                                 ]
                                               )
puts "\n#{additional_related_mainstream_content_urls.length} Additional related mainstream content urls"

additional_related_mainstream_content_urls.each do |detailed_guide|
  detailed_guide_id = detailed_guide.id
  additional_related_mainstream_content_url = detailed_guide.additional_related_mainstream_content_url

  next if detailed_guide?(detailed_guide_id, additional_related_mainstream_content_url)
  content_id = validate_url_content_id(additional_related_mainstream_content_url)
  if content_id.nil?
    chopped_url = clean_the_url(additional_related_mainstream_content_url)
    content_id = validate_url_content_id(chopped_url) if chopped_url
    update_additional_related_mainstream_url(detailed_guide_id, chopped_url) if !content_id.nil?
  end
  puts "Content item not found: #{detailed_guide_id}, #{additional_related_mainstream_content_url}" if content_id.nil?
end

note = "\nContent items not found need to be manually fixed.\n"
note << "Some (potentially all) of these will be fixed when\n"
note << "20160912131542_destroy_open_policy_making_toolkit_detailed_guide\n"
note << "is run."
puts note
