class AnnouncementFilterJsonPresenter < DocumentFilterJsonPresenter
  def as_json(options = nil)
    super.merge atom_feed_url: h.publication_atom_feed_url
  end

  def document_hash(document)
    super.merge(
      publication_date: h.render_datetime_microformat(document, :first_published_at) {
        document.first_published_at.to_s(:long_ordinal)
      }.html_safe,
      announcement_type: h.announcement_type(document)
    )
  end
end
