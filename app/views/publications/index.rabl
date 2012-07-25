object false
node :results do
  @publications.map { |a| {
      id: a.id,
      title: a.title,
      url: public_document_path(a),
      organisations: a.organisations.map { |o|
        organisation_display_name(o)
      }.to_sentence.html_safe,
      published: render_datetime_microformat(a, :publication_date) {
        a.publication_date.to_s(:long_ordinal)
      }.html_safe,
      publication_type: a.publication_type.singular_name
    }
  }
end
