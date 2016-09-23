module PublishingApi
  class FatalityNoticePresenter
    def initialize(item)
      @item = item
    end

    def content_id
      item.content_id
    end

    def content
      {}.tap { |content|
        content.merge!(BaseItemPresenter.new(item).base_attributes)
        content.merge!(PayloadBuilder::PublicDocumentPath.for(item))
        content.merge!(
          description: item.summary,
          document_type: "fatality_notice",
          public_updated_at: item.public_timestamp || item.updated_at,
          rendering_app: Whitehall::RenderingApp::WHITEHALL_FRONTEND,
          schema_name: "fatality_notice",
          details: details,
          links: links
        )
      }
    end

  private

    attr_reader :item

    def details
      {
        body: Whitehall::GovspeakRenderer.new.govspeak_edition_to_html(item),
        first_public_at: item.first_public_at,
        change_history: item.change_history.as_json,
        emphasised_organisations: item.lead_organisations.map(&:content_id)
      }
    end

    def links
      {
        organisations: item.organisations.map(&:content_id)
      }
    end
  end
end
