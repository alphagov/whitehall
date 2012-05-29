module DocumentHelper
  def published_or_updated(edition)
    edition.first_edition? ? 'published' : 'updated'
  end

  def change_history(doc_identity)
    history = doc_identity.editions_ever_published.map do |e|
      {published_at: e.published_at, change_note: e.change_note}
    end
    history.last[:change_note] ||= "First published." if history.last
    history.reject { |e| e[:change_note].blank? }
  end

  def edition_thumbnail_tag(edition)
    image_url = edition.has_thumbnail? ? edition.thumbnail_url : 'pub-cover.png'
    link_to image_tag(image_url), public_document_path(edition)
  end

  def edition_organisation_class(edition)
    if organisation = edition.organisations.first
      organisation.slug
    else
      'unknown_organisation'
    end
  end
end
