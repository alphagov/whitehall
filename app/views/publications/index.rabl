collection @publications

attributes :id, :title
node(:url) { |c| public_document_path(c) }
node(:organisations) { |c| c.organisations.map { |o|
    organisation_display_name(o)
  }.to_sentence.html_safe }
node(:published) { |c| render_datetime_microformat(c, :publication_date) {
    c.publication_date.to_s(:long_ordinal)
  }.html_safe }
node(:publication_type) { |c| c.publication_type.singular_name }
