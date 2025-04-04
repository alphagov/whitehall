module PublishingApi
  class CaseStudyPresenter
    include Presenters::PublishingApi::UpdateTypeHelper

    attr_accessor :item, :update_type

    def initialize(item, update_type: nil)
      self.item = item
      self.update_type = update_type || default_update_type(item)
    end

    delegate :content_id, to: :item

    def content
      BaseItemPresenter
        .new(item, update_type:)
        .base_attributes
        .merge(PayloadBuilder::PublicDocumentPath.for(item))
        .merge(PayloadBuilder::AccessLimitation.for(item))
        .merge(
          description: item.summary,
          details:,
          document_type:,
          public_updated_at: item.public_timestamp || item.updated_at,
          rendering_app: Whitehall::RenderingApp::FRONTEND,
          schema_name: "case_study",
          auth_bypass_ids: [item.auth_bypass_id],
        )
    end

    def links
      PayloadBuilder::Links.for(item).extract(
        %i[
          organisations
          world_locations
          worldwide_organisations
        ],
      )
    end

    def document_type
      "case_study"
    end

  private

    def details
      details_hash = {
        body:,
        change_history: item.change_history.as_json,
        emphasised_organisations: item.lead_organisations.map(&:content_id),
        first_public_at:,
        format_display_type: item.display_type_key,
      }
      details_hash[:image] = if image_available? && image_required? && item.lead_image_has_all_assets?
                               image_details
                             else
                               { url: "", caption: nil, alt_text: "" }
                             end
      details_hash.merge!(PayloadBuilder::TagDetails.for(item))
      details_hash.merge!(PayloadBuilder::PoliticalDetails.for(item))
    end

    def first_public_at
      return item.first_public_at if item.document.live?

      item.document.created_at.iso8601
    end

    def body
      Whitehall::GovspeakRenderer.new.govspeak_edition_to_html(item)
    end

    def image_details
      {
        url: item.lead_image_url,
        alt_text: item.lead_image_alt_text,
        caption: item.lead_image_caption,
      }
    end

    def image_available?
      item.lead_image.present? || item.emphasised_organisation_default_image_available?
    end

    def image_required?
      item.image_display_option != "no_image"
    end
  end
end
