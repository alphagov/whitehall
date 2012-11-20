class PublicationFilterJsonPresenter < DocumentFilterJsonPresenter
  def as_json(options = nil)
    super.merge atom_feed_url: h.filter_atom_feed_url
  end

  def document_hash(document)
    to_merge = {
      publication_date: document.display_date_microformat,
      organisations: "",
      publication_type: document.display_publication_type,
      type: "",
      publication_series: ""
    }
    if document.part_of_series?
      link = h.link_to(document.document_series.name, h.organisation_document_series_path(document.document_series.organisation, document.document_series))
      to_merge[:publication_series] = "Part of a series: #{link}".html_safe
    end

    super.reverse_merge(to_merge)
  end
end
