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
      content.merge!(BaseItemPresenter.new(item).base_attributes)
      content[:description] = item.summary
      content
    end

  private

    attr_reader :item
  end
end
