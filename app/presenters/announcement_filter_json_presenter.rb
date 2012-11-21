class AnnouncementFilterJsonPresenter < DocumentFilterJsonPresenter
  def as_json(options = nil)
    super.merge atom_feed_url: h.filter_atom_feed_url
  end

  def document_hash(document)
    super.merge(
      publication_date: document.display_date_microformat,
      announcement_type: document.display_type
    )
  end
end
