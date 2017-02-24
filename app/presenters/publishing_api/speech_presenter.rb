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
      content = BaseItemPresenter.new(item).base_attributes
      content.merge!(
        description: item.summary,
        details: details,
        document_type: document_type,
        public_updated_at: item.public_timestamp || item.updated_at,
        #TODO: rendering app is hard coded until format is ready
        #rendering_app: Whitehall::RenderingApp::GOVERNMENT_FRONTEND,
        rendering_app: "whitehall-frontend",
        schema_name: "speech",
      )
      content.merge!(PayloadBuilder::PublicDocumentPath.for(item))
      content.merge!(PayloadBuilder::AccessLimitation.for(item))
      content.merge!(PayloadBuilder::FirstPublishedAt.for(item))
    end

    def details
      details = {
        body: body,
        political: item.political,
        delivered_on: item.delivered_on.iso8601,
        change_history: item.change_history.as_json,
      }
      details.merge!(image_payload) if speaker_has_image?
      details.merge!(PayloadBuilder::PoliticalDetails.for(item))
      details.merge!(PayloadBuilder::FirstPublicAt.for(item))
    end

    def links
      links = LinksPresenter.new(item).extract([:organisations, :policy_areas])
      links.merge!(links_for_policies)
      links.merge!(links_for_speaker)
      links.merge!(links_for_topical_events)
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

    def image_payload
      {
        image: {
          alt_text: speaker.name,
          url: speaker.image.url,
        }
      }
    end

    def links_for_policies
      { policies: item.policy_content_ids }
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
  end
end
