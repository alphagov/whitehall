slugs = %w[
  countryside-stewardship-facilitation-funding
  countryside-stewardship-water-capital-grants-2015-capital-items
  countryside-stewardship-water-capital-grants-catchment-sensitive-farming
  countryside-stewardship-woodland-capital-grants-2015
  countryside-productivity-scheme
  rural-development-programme-for-england-leader-funding
]
logo_url = "https://assets.digital.cabinet-office.gov.uk/media/55547b94ed915d15d8000057/european-agricultural-fund-for-rural-development.gif"

puts "Adding logos to EAFRD editions"
slugs.each do |slug|
  document = Document.find_by(slug:)
  latest_published_edition = document.live_edition
  draft_edition = document.editions.latest_edition.draft.first

  puts "Updating logo in #{slug} published version"
  latest_published_edition.update_column(:logo_url, logo_url)

  if draft_edition
    puts "Updating logo in #{slug} draft version"
    draft_edition.update_column(:logo_url, logo_url)
  end
end
