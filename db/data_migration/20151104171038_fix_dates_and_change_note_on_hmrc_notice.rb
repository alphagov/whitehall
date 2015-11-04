document = Document.find_by(slug: 'excise-notice-476-tobacco-products-duty')

wrong_edition = document.editions[3]
wrong_edition.update_columns(
  published_major_version: 1,
  published_minor_version: 3,
  change_note: "",
  minor_change: true,
)

published_edition = document.published_edition
published_edition.update_columns(
  first_published_at: "2012-08-01 09:00:00",
  major_change_published_at: "2014-01-01 09:00:00",
  public_timestamp: "2014-01-01 09:00:00",
  published_major_version: 1,
  published_minor_version: 4,
)

artefact = RegisterableEdition.new(published_edition)
registerer = GdsApi::Panopticon::Registerer.new(owning_app: 'whitehall', rendering_app: 'whitehall-frontend', kind: artefact.kind)
puts "Registering /#{artefact.slug} with Panopticon..."
registerer.register(artefact)

puts "Registering /#{artefact.slug} with Search..."
Whitehall::SearchIndex.add(document.published_edition)
