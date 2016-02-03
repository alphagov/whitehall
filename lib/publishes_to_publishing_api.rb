module PublishesToPublishingApi
  extend ActiveSupport::Concern
  include HasContentId

  included do
    after_commit :publish_to_publishing_api, if: :can_publish_to_publishing_api?
    after_commit :publish_gone_to_publishing_api, on: :destroy
  end

  def can_publish_to_publishing_api?
    persisted?
  end

  def publish_to_publishing_api
    Whitehall::PublishingApi.publish_async(self)
  end

  def publish_gone_to_publishing_api
    Whitehall::PublishingApi.publish_gone(search_link)
  end
end
