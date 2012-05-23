module DocumentHelper
  def published_or_updated(document)
    document.first_edition? ? 'published' : 'updated'
  end

  def change_history(document)
    history = document.editions_ever_published.map do |e|
      {published_at: e.published_at, change_note: e.change_note}
    end
    history.last[:change_note] ||= "First published." if history.last
    history.reject { |e| e[:change_note].blank? }
  end

  def document_thumbnail_tag(document)
    image_url = document.has_thumbnail? ? document.thumbnail_url : 'pub-cover.png'
    link_to image_tag(image_url), public_document_path(document)
  end

  def document_organisation_class(document)
    if organisation = document.organisations.first
      organisation.slug
    else
      'unknown_organisation'
    end
  end
end
