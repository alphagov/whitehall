class AnnouncementFilterJsonPresenter < DocumentFilterJsonPresenter
  def as_json(options = nil)
    super.merge atom_feed_url: h.filter_atom_feed_url
  end

  def document_hash(document)
    hash = super
    if (document.has_operational_field?)
      hash.merge!(field_of_operation: "Field of operation: " + h.link_to(document.operational_field.name, document.operational_field))
    end
    if document.respond_to?(:part_of_series?) && document.part_of_series?
      links = document.document_series.map do |ds|
        h.link_to(ds.name, h.organisation_document_series_path(ds.organisation, ds))
      end
      hash.merge!(publication_series:  "Part of a series: #{links.to_sentence}")
    end
    hash.merge(
      display_date_microformat: document.display_date_microformat,
      announcement_type: document.display_type
    )
  end
end
