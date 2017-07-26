module PublishingApi
  class CaseStudyPresenter
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
        document_type: "case_study",
        public_updated_at: item.public_timestamp || item.updated_at,
        rendering_app: Whitehall::RenderingApp::GOVERNMENT_FRONTEND,
        schema_name: "case_study",
      )
      content.merge!(PayloadBuilder::PublicDocumentPath.for(item))
      content.merge!(PayloadBuilder::AccessLimitation.for(item))
    end

    def links
      LinksPresenter.new(item).extract(
        [
          :organisations,
          :parent,
          :related_policies,
          :topics,
          :world_locations,
          :worldwide_organisations,
        ]
      )
    end

  private

    def details
      details_hash = {
        body: body,
        change_history: item.change_history.as_json,
        emphasised_organisations: item.lead_organisations.map(&:content_id),
        first_public_at: first_public_at,
        format_display_type: item.display_type_key,
      }
      details_hash[:image] = image_details if image_available?
      details_hash.merge!(PayloadBuilder::TagDetails.for(item))
    end

    def first_public_at
      return item.first_public_at if item.document.published?
      item.document.created_at.iso8601
    end

    def body
      Whitehall::GovspeakRenderer.new.govspeak_edition_to_html(item)
    end

    def image_details
      {
        url: Whitehall.public_asset_host + presented_case_study.lead_image_path,
        alt_text: presented_case_study.lead_image_alt_text,
        caption: presented_case_study.lead_image_caption,
      }
    end

    def image_available?
      item.images.any? || emphasised_organisation_default_image_available?
    end

    def emphasised_organisation_default_image_available?
      item.lead_organisations.first.default_news_image.present?
    end

    def presented_case_study
      ::CaseStudyPresenter.new(item)
    end
  end
end
