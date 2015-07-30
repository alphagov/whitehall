require 'csv'

csv_filename = __FILE__.sub(/rb\z/, 'csv')
CSV.foreach(csv_filename, headers: true) do |row|
  document_type, slug = row.fetch("document_type"), row.fetch("slug")

  document = Document.at_slug(document_type, slug)
  raise "Failed to find #{document_type} with slug '#{slug}'" if document.nil?

  edition = document.published_edition
  raise "No published edition found for #{slug}" if edition.nil?

  artefact = RegisterableEdition.new(edition)
  registerer = GdsApi::Panopticon::Registerer.new(owning_app: 'whitehall', rendering_app: 'whitehall-frontend', kind: artefact.kind)

  puts "Registering /#{artefact.slug} with Panopticon..."
  registerer.register(artefact)
end
