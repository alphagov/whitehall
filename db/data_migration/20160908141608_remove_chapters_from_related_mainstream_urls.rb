#This script removes the last part of a slug for related mainstream content urls that are linking to a chapter of a related mainstream content instead of the related mainstream document.
require 'gds-api-adapters'

def validate_url_content_id(url)
  url = url.chomp
  base_path = url[18..-1] if url.length > 17
  content_id = Whitehall.publishing_api_v2_client.lookup_content_id(base_path: base_path) if base_path
  content_id
end

def write_to_file(file_name, params)
  File.open(file_name, "a+") do |f|
    params.each do |param|
      f.write "#{param}, "
    end
    f.write "\n"
  end
end

def detailed_guide?(id, url)
  write_to_file("related_mainstream_content.detailed_guide_items_found", [id, url]) if url.start_with?("https://www.gov.uk/guidance/")
  url.start_with?("https://www.gov.uk/guidance/")
end

def update_mainstream_url(id, clean_url)
  detailed_guide = DetailedGuide.find(id)
  incorrect_url = detailed_guide.related_mainstream_content_url
  #detailed_guide.update_attribute(:related_mainstream_content_url, clean_url)
  write_to_file("related_mainstream_content.related_content_found_and_updated", [id, incorrect_url, clean_url])
end

def update_additional_related_mainstream_url(id, clean_url)
  detailed_guide = DetailedGuide.find(id)
  incorrect_url = detailed_guide.additional_related_mainstream_content_url
  #detailed_guide.update_attribute(:additional_related_mainstream_content_url, clean_url)
  write_to_file("related_mainstream_content.related_content_found_and_updated", [id, incorrect_url, clean_url])
end

def clean_the_url(url)
  clean_url = url[/(https:\/\/www.gov.uk\/)(.*)\//]
  if !clean_url.nil?
    clean_url = clean_url.chop if clean_url[-1] == "/"
  end
  clean_url
end

files = %w(related_mainstream_content.original_url_already_perfect
          related_mainstream_content.content_items_not_found
          related_mainstream_content.detailed_guide_items_found
          related_mainstream_content.related_content_found_and_updated)
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
    write_to_file("related_mainstream_content.original_url_already_perfect", [detailed_guide[:id], content_id, detailed_guide[:related_mainstream_content_url]])
  end
  write_to_file("related_mainstream_content.content_items_not_found", [detailed_guide[:id], detailed_guide[:related_mainstream_content_url]]) if content_id.nil?
end

# add some space to the files before additional related mainstream content
files.each do |file|
  write_to_file(file, ["\n--------------------------------\n"])
end

p "---"
p "Additional related mainstream content"
p "---"

additional_related_mainstream_content_urls = DetailedGuide.select(
                                    :id,
                                    :additional_related_mainstream_content_url
                                  ).where([
                                    "additional_related_mainstream_content_url IS NOT NULL
                                    AND additional_related_mainstream_content_url != ''"
                                  ])
n = 0
additional_related_mainstream_content_urls.each do |detailed_guide|
  detailed_guide_id = detailed_guide.id
  additional_related_mainstream_content_url = detailed_guide.additional_related_mainstream_content_url
  p "#{detailed_guide_id} #{n += 1}/#{additional_related_mainstream_content_urls.length}"

  next if detailed_guide?(detailed_guide_id, additional_related_mainstream_content_url)
  content_id = validate_url_content_id(additional_related_mainstream_content_url)
  if content_id.nil?
    chopped_url = clean_the_url(additional_related_mainstream_content_url)
    content_id = validate_url_content_id(chopped_url) if chopped_url
    update_additional_related_mainstream_url(detailed_guide_id, chopped_url) if !content_id.nil?
  else
    write_to_file("related_mainstream_content.original_url_already_perfect", [detailed_guide_id, content_id, additional_related_mainstream_content_url])
  end
  write_to_file("related_mainstream_content.content_items_not_found", [detailed_guide_id, additional_related_mainstream_content_url]) if content_id.nil?
end
