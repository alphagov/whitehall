slugs = %w[
  erdf-programmes-and-resources
  erdf-programmes-progress-and-achievements
  applying-for-erdf-funding
  erdf-national-guidance
  previous-erdf-programmes-retaining-documents
  european-territorial-cooperation-programmes
  reuniting-europe-programme-turkey
]
logo_url = "https://assets.digital.cabinet-office.gov.uk/media/55a7cc72ed915d5374000001/erdf-logo.png"

puts "Adding logos to ERDF editions"
slugs.each do |slug|
  document = Document.find_by(document_type: "DetailedGuide", slug: slug)
  latest_published_edition = document.live_edition
  draft_edition = document.editions.latest_edition.draft.first

  puts "Updating logo in #{slug} published version"
  latest_published_edition.update_column(:logo_url, logo_url)

  if draft_edition
    puts "Updating logo in #{slug} draft version"
    draft_edition.update_column(:logo_url, logo_url)
  end
end
