class DocumentExportPresenter < Whitehall::Decorators::Decorator
  include GovspeakHelper

  DOCUMENT_SUB_TYPES = %i[
    news_article_type
    publication_type
    corporate_information_page_type
    speech_type
  ].freeze

  def as_json
    {
      document: model,
      editions: editions,
    }
  end

  private

  def editions
    model.editions.map do |edition|
      {
        edition: edition,
        government: edition.government,
        whitehall_admin_links: resolve_whitehall_admin_links(edition),
        associations: {
          attachments: complete_attachments(edition),
          images: complete_images(edition),
        },
      }.merge(provide_doctype_information(edition))
    end
  end

  def complete_images(edition)
    images = edition.try(:images)
    return [] unless images

    images.map do |image|
      image.as_json(methods: :url)
    end
  end

  def complete_attachments(edition)
    attachments = edition.try(:attachments)
    return [] unless attachments

    attachments.map do |attachment|
      attachment.as_json(include: :attachment_data, methods: %i[url type]).tap do |json|
        json.merge!("govspeak_content" => attachment.govspeak_content.as_json) if attachment.respond_to?(:govspeak_content)
      end
    end
  end

  def provide_doctype_information(edition)
    DOCUMENT_SUB_TYPES.each_with_object({}) do |type, memo|
      memo[type] = edition.public_send(type)&.key if edition.respond_to?(type)
    end
  end

  def resolve_whitehall_admin_links(edition)
    links = admin_links(edition.body)

    if edition.withdrawn?
      links.concat(admin_links(edition.unpublishing.explanation))
    end

    links
  end

  def admin_links(text)
    whitehall_admin_links(text).map do |link|
      { whitehall_admin_url: link, public_url: public_url_for_admin_link(link) }
    end
  end

  def public_url_for_admin_link(url)
    edition = Whitehall::AdminLinkLookup.find_edition(url)
    Whitehall.url_maker.public_document_url(edition) if edition.present?
  end
end
