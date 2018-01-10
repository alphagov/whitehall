# Fix mainstream and additional mainstream urls identified as being not found
# by our previous migration (remove_chapters_from_related_mainstream_urls)
# The idea is to create a hash which has the old, unfound url as the key
# and the new url as the value, then iterate through the hash and do the
# update.
# It ignores editions with a state of 'superseded'.
# This script might need to be updated depending on how much the data has
# changed between testing and deploying.

# This does the update - field_name should either be
# :related_mainstream_content_url or
# :additional_related_mainstream_content_url
# depending on which field is to be updated
def update_related_mainstream_url(field_name, current_mainstream_url, fixed_url)
  detailed_guides = DetailedGuide.where(field_name => current_mainstream_url).where.not(state: 'superseded')

  detailed_guides.each do |detailed_guide|
    detailed_guide.update_attribute(field_name, fixed_url)
    puts "Fixed #{detailed_guide.id}, #{field_name}, #{current_mainstream_url}, #{fixed_url}"
  end
end

def iterate_and_update(mainstream_or_additional_mainstream_field_name, urls)
  urls.each do |current_url, fixed_url|
    update_related_mainstream_url(mainstream_or_additional_mainstream_field_name, current_url, fixed_url)
  end
end

def fix_related_mainstream_content_urls
  urls = {
    'https://www.gov.uk/freight-forwarders' => 'https://www.gov.uk/guidance/freight-forwarding-moving-goods',
    'https://www.gov.uk/exportcontrol' => 'https://www.gov.uk/starting-to-export',
    'https://www.gov.uk/buy-a-uk-fishing-rod-licence' => 'https://www.gov.uk/fishing-licences',
    'www.gov.uk/mutuals' => 'https://www.gov.uk/government/get-involved/take-part/start-a-public-service-mutual',
    '/vat-rates' => 'https://www.gov.uk/vat-rates',
    'https://www.gov.uk/uk-welcomes-business' => 'https://www.gov.uk/set-up-business-uk',
  }
  iterate_and_update(:related_mainstream_content_url, urls)
end

def fix_additional_mainstream_content_urls
  urls = {
    '/vat-businesses' => 'https://www.gov.uk/vat-businesses',
    'https://www.gov.uk/freight-forwarders' => 'https://www.gov.uk/guidance/freight-forwarding-moving-goods',
  }
  iterate_and_update(:additional_related_mainstream_content_url, urls)
end

fix_related_mainstream_content_urls
fix_additional_mainstream_content_urls
