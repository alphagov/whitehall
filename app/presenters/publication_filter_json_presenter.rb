class PublicationFilterJsonPresenter < DocumentFilterJsonPresenter
  def as_json(options = nil)
    super.merge atom_feed_url: h.publication_atom_feed_url
  end

  def document_hash(document)
    to_merge = {
      publication_date: h.render_datetime_microformat(document, :publication_date) {
        document.publication_date.to_s(:long_ordinal)
      }.html_safe,
      publication_type: document.publication_type.singular_name,
      publication_series: ""
    }
    if document.part_of_series?
      link = h.link_to(document.document_series.name, h.organisation_document_series_path(document.document_series.organisation, document.document_series))
      to_merge[:publication_series] = "Part of a series: #{link}".html_safe
    end

    super.merge(to_merge)
  end
end
