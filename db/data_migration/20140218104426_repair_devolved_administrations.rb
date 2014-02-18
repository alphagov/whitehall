require 'ostruct'

NEW_SLUGS_TO_EDITION_IDS = {
  "the-scottish-government"     => [288802],
  "welsh-government"            => [225916, 226421, 228957, 229461, 237089, 237185, 242230, 247255, 247606, 247906, 280474],
  "northern-ireland-executive"  => [229244, 233120, 274557, 290099]
}

# Remap old documents to new organisations
NEW_SLUGS_TO_EDITION_IDS.each do |new_slug, edition_ids|
  if organisation = Organisation.where(slug: new_slug).first
    puts "Adding editions #{edition_ids} to #{organisation.name}"
    organisation.edition_ids = edition_ids
  else
    puts "Organisation with sug #{new_slug} not found."
  end
end
