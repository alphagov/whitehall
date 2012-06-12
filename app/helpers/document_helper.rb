module DocumentHelper
  def published_or_updated(edition)
    edition.first_edition? ? 'published' : 'updated'
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
