class ExportNewsDocument
  EDITION_FIELDS = %i[
    id
    created_at
    updated_at
    lock_version
    state
    type
    major_change_published_at
    first_published_at
    change_note
    force_published
    minor_change
    public_timestamp
    scheduled_publication
    access_limited
    published_major_version
    published_minor_version
    primary_locale
    political
  ].freeze

  attr_reader :document

  def initialize(document)
    @document = document
  end

  def call
    document.as_json.merge("editions" => editions.as_json)
  end

private

  def editions
    document.editions.map do |edition|
      edition
        .as_json(only: EDITION_FIELDS)
        .merge(edition_associations(edition))
    end
  end

  def edition_associations(edition)
    {
      alternative_format_provider: organisation(edition.alternative_format_provider),
      news_article_type: edition.news_article_type&.as_json,
      translations: translations(edition),
      unpublishing: unpublishing(edition),
      last_author: edition.last_author&.uid,
      authors: edition.authors.map(&:uid),
      # These specialist sectors map to document types of topic
      primary_specialist_sectors: edition.primary_specialist_sectors.map(&:topic_content_id),
      secondary_specialist_sectors: edition.secondary_specialist_sectors.map(&:topic_content_id),
      lead_organisations: edition.lead_organisations.map(&:content_id),
      supporting_organisations: edition.supporting_organisations.map(&:content_id),
      topics: edition.topics.map { |t| t.as_json(only: %i[id content_id name type]) },
      policy_content_ids: edition.policy_content_ids,
      world_locations: edition.world_locations.map(&:content_id),
      worldwide_organisations: edition.worldwide_organisations.map(&:content_id),
      ministers: ministers(edition),
      topical_events: TopicalEvent.for_edition(edition.id).map(&:content_id),
      images: images(edition),
      attachments: attachments(edition),
    }
  end

  def organisation(organisation)
    return unless organisation
    organisation
      .as_json(only: %i[id content_id name])
      .merge(type: "Organisation")
  end

  def translations(edition)
    edition.translations.map do |translation|
      base_path = Whitehall.url_maker.public_document_path(edition, locale: translation.locale)

      translation
        .as_json(only: %i[locale title summary body])
        .merge(base_path: base_path)
    end
  end

  def unpublishing(edition)
    return unless edition.unpublishing
    edition.unpublishing
      .as_json(only: %i[explanation alternative_url redirect])
      .merge(reason: edition.unpublishing.unpublishing_reason.name)
  end

  def ministers(edition)
    edition.role_appointments.map do |appointment|
      {
        id: appointment.id,
        content_id: appointment.content_id,
        role: {
          id: appointment.role.id,
          content_id: appointment.role.content_id,
        },
        person: {
          id: appointment.person.id,
          content_id: appointment.person.content_id,
        },
      }
    end
  end

  def images(edition)
    edition.images.map do |image|
      {
        id: image.id,
        alt_text: image.alt_text,
        caption: image.caption,
        carrierwave_image: image.image_data.carrierwave_image,
      }
    end
  end

  def attachments(edition)
    edition.attachments.map do |attachment|
      data = attachment.as_json(except: %i[attachable_id attachable_type attachment_data_id])

      if attachment.respond_to?(:attachment_data)
        data[:attachment_data] =  attachment.attachment_data.as_json
      end

      if attachment.respond_to?(:govspeak_content)
        data[:govspeak_content] = attachment.govspeak_content.as_json(
          expect: :html_attachment_id
        )
      end

      data
    end
  end
end
