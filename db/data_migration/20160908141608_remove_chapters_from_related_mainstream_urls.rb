#This script removes the last part of a slug for related mainstream content urls that are linking to a chapter of a related mainstream content instead of the related mainstream document.
require 'gds-api-adapters'

def validate_url_content_id(url)
  url = url.chomp
  base_path = url[18..-1] if url.length > 17
  content_id = Whitehall.publishing_api_v2_client.lookup_content_id(base_path: base_path) if base_path
  p base_path
  p content_id
  content_id
end


def write_detailed_guide_to_file(id, url)
  File.open("improve_mainstream_content.detailed_guide_items_found", "a+") do |f|
    f.write "#{id}, #{url}\n"
  end
end

def write_content_items_not_found_to_file(id, url)
  File.open("improve_mainstream_content.content_items_not_found", "a+") do |f|
    f.write "#{id}, #{url}\n"
  end
end

def write_updated_items_to_file(id, old_url, updated_url)
  File.open("improve_mainstream_content.related_content_found_and_updated", "a+") do |f|
    f.write "#{id}, #{old_url}, #{updated_url}\n"
  end
end

def write_items_that_dont_need_updating(id, old_url, content_id)
  File.open("improve_mainstream_content.original_url_already_perfect", "a+") do |f|
    f.write "#{id}, #{content_id}, #{old_url}\n"
  end
end

def detailed_guide?(id, url)
  write_detailed_guide_to_file(id, url) if url.start_with?("https://www.gov.uk/guidance/")
  url.start_with?("https://www.gov.uk/guidance/")
end

def update_mainstream_url(id, clean_url)
  detailed_guide = DetailedGuide.find(id)
  incorrect_url = detailed_guide.related_mainstream_content_url
  #detailed_guide.update_attribute(:related_mainstream_content_url, clean_url)
  write_updated_items_to_file(id, incorrect_url, clean_url)
end

def clean_the_url(url)
  clean_url = url[/(https:\/\/www.gov.uk\/)(.*)\//]
  if !clean_url.nil?
    clean_url = clean_url.chop if clean_url[-1] == "/"
  end
  clean_url
end

files = %w(improve_mainstream_content.original_url_already_perfect
          improve_mainstream_content.content_items_not_found
          improve_mainstream_content.detailed_guide_items_found
          original_url_already_perfect.related_content_found_and_updated)
files.each do |f|
  File.delete(f) if File.exists?(f)
end

related_mainstream_content_urls = DetailedGuide.select(
                                    :id,
                                    :related_mainstream_content_url
                                  ).where([
                                    "related_mainstream_content_url IS NOT NULL
                                    AND related_mainstream_content_url != ''
                                    AND state != 'superseded'"
                                  ])
n = 0
related_mainstream_content_urls.each do |detailed_guide|
  p "#{detailed_guide[:id]} #{n += 1}/#{related_mainstream_content_urls.length}"
  next if detailed_guide?(detailed_guide[:id], detailed_guide[:related_mainstream_content_url])
  content_id =  validate_url_content_id(detailed_guide[:related_mainstream_content_url])
  if content_id.nil?
    chopped_url = clean_the_url(detailed_guide[:related_mainstream_content_url])
    content_id = validate_url_content_id(chopped_url) if chopped_url
    update_mainstream_url(detailed_guide[:id], chopped_url) if !content_id.nil?
  else
    write_items_that_dont_need_updating(detailed_guide[:id], content_id, detailed_guide[:related_mainstream_content_url])
  end
  write_content_items_not_found_to_file(detailed_guide[:id], detailed_guide[:related_mainstream_content_url]) if content_id.nil?
end


# additional_related_mainstream_content_urls = DetailedGuide.select(
#                                     :id,
#                                     :additional_related_mainstream_content_url
#                                   ).where([
#                                     "additional_related_mainstream_content_url IS NOT NULL
#                                     AND additional_related_mainstream_content_url != ''"
#                                   ])
#
# additional_related_mainstream_content_urls.each do |detailed_guide|
#   p detailed_guide[:id]
#   p detailed_guide[:additional_related_mainstream_content_url]
#   next if detailed_guide?(detailed_guide[:additional_related_mainstream_content_url])
#   clean_url = detailed_guide[:additional_related_mainstream_content_url][/(https:\/\/www.gov.uk\/)(.*)\//]
#   if !clean_url.nil?
#     clean_url = clean_url.chop if clean_url[-1] == "/"
#     detailed_guide_to_update = DetailedGuide.find(detailed_guide[:id])
#     detailed_guide_to_update.update_attribute(:additional_related_mainstream_content_url, clean_url)
#     p detailed_guide_to_update.additional_related_mainstream_content_url
#   end
# end
