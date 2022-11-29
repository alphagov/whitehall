class DocumentExportPresenter < Whitehall::Decorators::Decorator
  include GovspeakHelper

  DOCUMENT_SUB_TYPES = %i[
    news_article_type
    publication_type
    corporate_information_page_type
    speech_type
  ].freeze

  def as_json
    presented_editions = model.editions.order(:id).map { |e| present_edition(e) }
    presented_users = users.map { |u| present_user(u) }
    model.as_json
         .merge(editions: presented_editions, users: presented_users)
         .deep_symbolize_keys
  end

private

  def present_edition(edition)
    document_subtype_ids = DOCUMENT_SUB_TYPES.map { |type| "#{type}_id" }
    except = %w[title summary body] + document_subtype_ids

    edition.as_json(except:).merge(
      alternative_format_provider_content_id: edition.try(:alternative_format_provider)&.content_id,
      attachments: present_attachments(edition),
      authors: edition.authors.pluck(:id).uniq,
      contacts: present_contacts(edition),
      editorial_remarks: present_editorial_remarks(edition),
      fact_check_requests: present_fact_check_requests(edition),
      government: edition.government&.as_json,
      revision_history: present_revision_history(edition),
      images: present_images(edition),
      organisations: present_organisations(edition),
      role_appointments: slice_association(edition, %i[role_appointment role_appointments], %i[id content_id]),
      specialist_sectors: slice_association(edition, :specialist_sectors, %i[id topic_content_id primary]),
      topical_events: slice_association(edition, :topical_events, %i[id content_id]),
      translations: present_translations(edition),
      unpublishing: present_unpublishing(edition),
      whitehall_admin_links: AdminLinkResolver.call(edition),
      world_locations: slice_association(edition, :world_locations, %i[id content_id]),
      worldwide_organisations: slice_association(edition, %i[worldwide_organisation worldwide_organisations], %i[id content_id]),
    ).merge(sub_document_type(edition))
  end

  def sub_document_type(edition)
    DOCUMENT_SUB_TYPES.index_with do |type|
      edition.try(type)&.key
    end
  end

  def present_contacts(edition)
    contacts = Govspeak::ContactsExtractor.new(edition.body).contacts
    contacts.map { |contact| contact.as_json(only: %i[id content_id]) }
  end

  def slice_association(edition, associations, fields)
    association_data = Array(associations).flat_map { |a| edition.try(a) }.compact
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
                .merge(variants: attachment_variants(attachment))
    end
  end

  def attachment_variants(attachment)
    return unless attachment.try(:attachment_data)

    attachment.attachment_data.file.versions.transform_values do |details|
      {
        content_type: details.content_type,
        url: details.url,
      }
    end
  end

  def present_editorial_remarks(edition)
    return [] unless edition.try(:editorial_remarks)

    edition.editorial_remarks.map do |remark|
      remark.as_json(only: %i[id body created_at author_id])
    end
  end

  def present_fact_check_requests(edition)
    return [] unless edition.try(:fact_check_requests)

    edition.fact_check_requests.map(&:as_json)
  end

  def present_revision_history(edition)
    edition.versions.map do |version|
      version.as_json(only: %w[created_at event state])
             .merge(whodunnit: version.whodunnit.to_i)
    end
  end

  def present_images(edition)
    return [] unless edition.try(:images)

    edition.images.map do |image|
      image["alt_text"].squish! if image["alt_text"]
      image["caption"].strip! if image["caption"]
      image.as_json(methods: :url)
           .merge(variants: image_variants(image))
    end
  end

  def image_variants(image)
    image.image_data.file.versions.each_with_object({}) do |(variant, details), memo|
      memo[variant] = details.url if details.url
    end
  end

  def present_organisations(edition)
    edition_organisations = edition.try(:edition_organisations) || edition.try(:edition_organisation)

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
      base_path = edition.public_path(locale: translation.locale)
      translation.as_json(except: :edition_id).merge(base_path:)
    end
  end

  def present_unpublishing(edition)
    return unless edition.unpublishing

    unpublishing_data = {
      unpublishing_reason: edition.unpublishing.unpublishing_reason.name,
      alternative_path: edition.unpublishing.alternative_path,
    }

    edition
      .unpublishing
      .as_json(
        only: %i[
          id
          explanation
          redirect
          created_at
          updated_at
        ],
      )
      .merge(unpublishing_data)
  end

  def present_user(user)
    {
      id: user.id,
      uid: user.uid,
      name: user.name,
      email: user.email,
      organisation_slug: user.organisation_slug,
      organisation_content_id: user.organisation_content_id,
    }
  end

  def users
    user_ids = model.editions.inject([]) do |memo, edition|
      whodunnits = edition.versions.pluck(:whodunnit).map(&:to_i)
      remarkers = edition.editorial_remarks.pluck(:author_id)
      requestors = edition.try(:fact_check_requests)&.pluck(:requestor_id).to_a
      authors = edition.authors.pluck(:id)

      memo + whodunnits + remarkers + requestors + authors
    end

    User.where(id: user_ids).order(:id)
  end

  class AdminLinkResolver
    include GovspeakHelper

    def self.call(*args)
      new.call(*args)
    end

    def call(edition)
      links = edition.translations.flat_map { |t| admin_links(t.body) }

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
