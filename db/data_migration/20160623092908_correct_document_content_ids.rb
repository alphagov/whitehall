# Documents with the following slugs exist in Whitehall.
slugs_to_fix = %w{
  how-to-appeal-your-rateable-value
  cma-opens-consultation-on-reed-elsevier-undertakings
  uk-visa-operations-in-south-india-are-impacted-by-the-floods-in-chennai
  common-land-guidance-for-commons-registration-authorities-and-applicants
  rpa-remains-on-track-to-pay-bps-2015-claims-from-december
}

# Each of these documents have published editions and render correctly on the
# Whitehall frontend.
# None of them have corresponding content items in the content store.
# They do however, have corresponding items in the publishing API database
# (matching on the base_path determined by Whitehall's url_maker).

# The content IDs recorded in Whitehall for these items do not match anything
# in the publishing API. The content IDs in the publishing API, however, match
# 5 'similar' documents in Whitehall:
obsolete_slugs = %w{
  deleted-how-to-appeal-your-rateable-value
  deleted-uk-visa-operations-in-south-india-are-impacted-by-the-floods-in-chennai
  deleted-common-land-guidance-for-commons-registration-authorities-and-applicants
  deleted-rpa-remains-on-track-to-pay-bps-2015-claims-from-december
}

# These appear to be junk documents with no corresponding editions, and can be
# safely deleted.
obsolete_slugs.each do |slug|
  doc = Document.where(slug: slug).first
  if doc.present?
    doc.destroy!
    puts "Destroyed #{slug}"
  else
    puts "Not found: #{slug}"
  end
end

# As for the 'good' documents with incorrect content IDs, we can fetch the
# correct IDs from the content store and set them accordingly:
slugs_to_fix.each do |slug|
  document = Document.find_by(slug: slug)
  base_path = Whitehall.url_maker.public_document_path(document.published_edition)
  correct_content_id = Services.publishing_api.lookup_content_id(base_path: base_path)
  if correct_content_id.blank?
    raise ArgumentError, "no content id found for #{base_path}"
  end
  document.content_id = correct_content_id
  document.save!
end
