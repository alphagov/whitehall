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
      content.merge!(BaseItemPresenter.new(item).base_attributes)
      content.merge!(PayloadBuilder::PublicDocumentPath.for(item))
      content
    end

  private

    attr_reader :item
  end
end
