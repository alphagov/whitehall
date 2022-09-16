logo_url = " https://assets.digital.cabinet-office.gov.uk/media/5540ab8aed915d15d8000030/european-structural-investment-funds.png"
slug = "england-2014-to-2020-european-structural-and-investment-funds"
document = Document.find_by(slug:, document_type: "DetailedGuide")
latest_published_edition = document.editions.latest_published_edition.first
draft_edition = document.editions.latest_edition.draft.first

if latest_published_edition
  puts "Updating logo in #{slug} published version"
  latest_published_edition.update_column(:logo_url, logo_url)
end

if draft_edition
  puts "Updating logo in #{slug} draft version"
  draft_edition.update_column(:logo_url, logo_url)
end
