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
        )
      }
    end

  private

    attr_reader :item
  end
end
