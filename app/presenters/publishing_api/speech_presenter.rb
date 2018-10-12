module PublishingApi
  class SpeechPresenter
    include UpdateTypeHelper

    attr_accessor :item
    attr_accessor :update_type

    def initialize(item, update_type: nil)
      self.item = item
      self.update_type = update_type || default_update_type(item)
    end

    def content_id
      item.content_id
    end

    def content
      content = BaseItemPresenter.new(item, update_type: update_type).base_attributes
      content.merge!(
        description: item.summary,
        details: details,
        document_type: document_type,
        public_updated_at: item.public_timestamp || item.updated_at,
        rendering_app: Whitehall::RenderingApp::GOVERNMENT_FRONTEND,
        schema_name: "speech",
      )
      content.merge!(PayloadBuilder::PublicDocumentPath.for(item))
      content.merge!(PayloadBuilder::AccessLimitation.for(item))
      content.merge!(PayloadBuilder::FirstPublishedAt.for(item))
    end

    def details
      # Some speeches and corporate information pages don't seem to
      # have first_published_at data, so ignore those change notes to
      # avoid violating the relevant content schema.
      changes_with_public_timestamps =
        item
          .change_history
          .select { |change| change[:public_timestamp].present? }

      details = {
        body: body,
        political: item.political,
        delivered_on: item.delivered_on.iso8601,
        change_history: changes_with_public_timestamps.as_json,
      }
      details.merge!(speech_type_explanation)
      details.merge!(image_payload) if has_image?
      details.merge!(PayloadBuilder::PoliticalDetails.for(item))
      details.merge!(PayloadBuilder::FirstPublicAt.for(item))
    end

    def links
      links = LinksPresenter.new(item).extract(
        %i[
          organisations
          policy_areas
          related_policies
          world_locations
        ]
      )
      links.merge!(links_for_speaker)
      links.merge!(links_for_topical_events)
      links.merge!(PayloadBuilder::Roles.for(item))
      links.merge!(PayloadBuilder::People.for(item, :people))
    end

  private

    def document_type
      if SpeechType.non_statements.include?(item.speech_type)
        "speech"
      else
        item.speech_type.key
      end
    end

    def body
      Whitehall::GovspeakRenderer.new.govspeak_edition_to_html(item)
    end

    def speech_type_explanation
      return {} unless item.speech_type
      return {} unless item.speech_type.explanation.present?

      { speech_type_explanation: item.speech_type.explanation }
    end

    def image_payload
      {
        image: {
          alt_text: alt_text,
          url: image.url
        }
      }
    end

    def links_for_speaker
      return {} unless speaker
      { speaker: [speaker.content_id] }
    end

    def links_for_topical_events
      { topical_events: item.topical_events.pluck(:content_id) }
    end

    def speaker
      item.role_appointment.person if item.role_appointment
    end

    def speaker_has_image?
      speaker && speaker.image && speaker.image.url
    end

    def speaker_image
      speaker_has_image? ? speaker.image : nil
    end

    def has_featured_image?
      !!(feature && feature.image)
    end

    def featured_image
      has_featured_image? ? feature.image : nil
    end

    def feature
      @feature ||= Feature.where(document_id: item.document_id).last
    end

    def image
      featured_image || speaker_image
    end

    def has_image?
      !!image
    end

    def alt_text
      if has_featured_image?
        feature.alt_text
      else
        speaker.name
      end
    end
  end
end
