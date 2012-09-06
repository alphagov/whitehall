class PublicationFilterJsonPresenter < DocumentFilterJsonPresenter
  def as_json(options = nil)
    super.merge atom_feed_url: h.publication_atom_feed_url
  end

  def document_hash(document)
    super.merge(
      publication_date: h.render_datetime_microformat(document, :publication_date) {
        document.publication_date.to_s(:long_ordinal)
      }.html_safe,
      publication_type: document.publication_type.singular_name
    )
  end
end
