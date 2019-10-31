class DocumentExportPresenter < Whitehall::Decorators::Decorator
  include GovspeakHelper

  DOCUMENT_SUB_TYPES = %i[
    news_article_type
    publication_type
    corporate_information_page_type
    speech_type
  ].freeze

  def as_json
    model.as_json
         .merge(editions: model.editions.map { |e| present_edition(e) })
         .deep_symbolize_keys
  end

  private

  def present_edition(edition)
    edition.as_json.merge(
      alternative_format_provider_content_id: edition.try(:alternative_format_provider)&.content_id,
      attachments: present_attachments(edition),
      authors: edition.authors.map { |u| present_user(u) },
      edition_policies: slice_association(edition, :edition_policies, %i[id policy_content_id]),
      fact_check_requests: present_fact_check_requests(edition),
      government: edition.government&.as_json,
      images: present_images(edition),
      last_author: present_user(edition.last_author),
      organisations: present_organisations(edition),
      role_appointments: slice_association(edition, %i[role_appointment role_appointments], %i[id content_id]),
      specialist_sectors: slice_association(edition, :specialist_sectors, %i[id topic_content_id primary]),
      topical_events: slice_association(edition, :topical_events, %i[id content_id]),
      translations: present_translations(edition),
      whitehall_admin_links: AdminLinkResolver.call(edition),
      world_locations: slice_association(edition, :world_locations, %i[id content_id]),
      worldwide_organisations: slice_association(edition, %i[worldwide_organisation worldwide_organisations], %i[id content_id]),
    ).merge(sub_document_type(edition))
  end

  def sub_document_type(edition)
    DOCUMENT_SUB_TYPES.each_with_object({}) do |type, memo|
      memo[type] = edition.try(type)&.key
    end
  end

  def slice_association(edition, associations, fields)
    association_data = Array(associations).flat_map { |a| edition.try(a) }.compact
    return [] unless association_data

    association_data.map { |item| item.as_json(only: fields) }
  end

  def present_attachments(edition)
    return [] unless edition.respond_to?(:attachments)

    edition.attachments.map do |attachment|
      govspeak_content = if attachment.respond_to?(:govspeak_content)
                           { govspeak_content: attachment.govspeak_content.as_json }
                         else
                           {}
                         end
      attachment.as_json(include: :attachment_data, methods: %i[url type])
                .merge(govspeak_content)
    end
  end

  def present_fact_check_requests(edition)
    return [] unless edition.try(:fact_check_requests)

    edition.fact_check_requests.map do |request|
      request.as_json(except: "requestor_id")
             .merge(requestor: present_user(request.requestor))
    end
  end

  def present_images(edition)
    return [] unless edition.try(:images)

    edition.images.map { |image| image.as_json(methods: :url) }
  end

  def present_organisations(edition)
    edition_organisations = edition.try(:edition_organisations) || edition.try(:edition_organisation)
    return [] unless edition_organisations

    Array(edition_organisations).map do |edition_organisation|
      organisation = edition_organisation.organisation
      {
        id: organisation.id,
        content_id: organisation.content_id,
        lead: edition_organisation.lead,
        lead_ordering: edition_organisation.lead_ordering,
      }
    end
  end

  def present_translations(edition)
    edition.translations.map do |translation|
      base_path = Whitehall.url_maker.public_document_path(edition, locale: translation.locale)
      translation.as_json(except: :edition_id).merge(base_path: base_path)
    end
  end

  def present_user(user)
    return {} unless user

    { id: user.id, uid: user.uid }
  end

  class AdminLinkResolver
    include GovspeakHelper

    def self.call(*args)
      new.call(*args)
    end

    def call(edition)
      links = admin_links(edition.body)

      if edition.unpublishing&.explanation
        links.concat(admin_links(edition.unpublishing.explanation))
      end

      links
    end

  private

    def admin_links(text)
      whitehall_admin_links(text).map do |link|
        edition = Whitehall::AdminLinkLookup.find_edition(link)
        {
          whitehall_admin_url: link,
          public_url: edition ? Whitehall.url_maker.public_document_url(edition) : nil,
          content_id: edition&.content_id,
        }
      end
    end
  end
end
