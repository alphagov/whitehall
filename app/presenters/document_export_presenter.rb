class DocumentExportPresenter < Whitehall::Decorators::Decorator
  include GovspeakHelper

  def as_json
    {
      document: model,
      editions: editions
    }
  end

  private

  def editions
    model.editions.map do |edition|
      edition_associations(edition)
    end
  end

  def edition_associations(edition)
    output = {
               "edition": edition,
               "associations": {},
               "whitehall_admin_links": []
             }

    associations = edition.class.reflect_on_all_associations.map(&:name)
    associations.each do |association|
      if association == :images
        edition_images = edition.public_send(association)
        output[:associations][association] = complete_images_hash(edition_images)
      else
        output[:associations][association] = edition.public_send(association)
      end
    end
    output[:whitehall_admin_links].concat(resolve_whitehall_admin_links(edition.body))
    if edition.withdrawn?
      output[:whitehall_admin_links].concat(resolve_whitehall_admin_links(edition.unpublishing.explanation))
    end
    output
  end

  def complete_images_hash(edition_images)
    edition_images.map do |image|
      image.as_json(methods: :url)
    end
  end

  def resolve_whitehall_admin_links(body)
    whitehall_admin_links(body).map do |link|
      { "whitehall_admin_url": link, "public_url": public_url_for_admin_link(link) }
    end
  end

  def public_url_for_admin_link(url)
    edition = Whitehall::AdminLinkLookup.find_edition(url)
    Whitehall.url_maker.public_document_url(edition) if edition.present?
  end
end
