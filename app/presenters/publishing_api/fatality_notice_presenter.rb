module PublishingApi
  class FatalityNoticePresenter
    def initialize(item)
      @item = item
    end

    def content_id
      item.content_id
    end

    def content
      content = {}
      content[:description] = item.summary
      content[:public_updated_at] = item.public_timestamp || item.updated_at
      content.merge!(BaseItemPresenter.new(item).base_attributes)
      content.merge!(PayloadBuilder::PublicDocumentPath.for(item))
      content[:rendering_app] = Whitehall::RenderingApp::WHITEHALL_FRONTEND
      content[:schema_name] = "fatality_notice"
      content
    end

  private

    attr_reader :item
  end
end
