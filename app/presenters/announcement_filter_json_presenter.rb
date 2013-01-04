class AnnouncementFilterJsonPresenter < DocumentFilterJsonPresenter
  def as_json(options = nil)
    super.merge atom_feed_url: h.filter_atom_feed_url
  end

  def document_hash(document)
    hash = super
    if (document.has_operational_field?)
      hash.merge!(field_of_operation: "Field of operation: " + h.link_to(document.operational_field.name, document.operational_field))
    end
    hash.merge(
      public_timestamp: document.display_date_microformat,
      announcement_type: document.display_type
    )
  end
end
