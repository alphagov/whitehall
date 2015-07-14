desc "Adds a logo to the last edition of a given slug"
task :add_logo, [ :slug, :document_type, :logo_url ] => :environment do |t, args|
  slug = args[:slug]
  document_type = args[:document_type]
  logo_url = args[:logo_url]

  document = Document.find_by(slug: slug, document_type: document_type)
  latest_published_edition = document.editions.latest_published_edition.first
  draft_edition = document.editions.latest_edition.draft.first

  puts "Updating logo in #{slug} published version"
  latest_published_edition.update_column(:logo_url, logo_url)

  if draft_edition
    puts "Updating logo in #{slug} draft version"
    draft_edition.update_column(:logo_url, logo_url)
  end
end
