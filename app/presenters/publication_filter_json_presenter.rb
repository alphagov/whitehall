class PublicationFilterJsonPresenter < DocumentFilterJsonPresenter
  def as_json(options = nil)
    super.merge atom_feed_url: h.filter_atom_feed_url
  end

  def document_hash(document)
    to_merge = {
      display_date_microformat: document.display_date_microformat,
      organisations: "",
      publication_type: document.display_type,
      type: "",
      publication_series: ""
    }
    if document.part_of_series?
      links = document.document_series.map do |ds|
        h.link_to(ds.name, h.organisation_document_series_path(ds.organisation, ds))
      end
      to_merge[:publication_series] = "Part of a series: #{links.to_sentence}".html_safe
    end

    super.reverse_merge(to_merge)
  end
end
