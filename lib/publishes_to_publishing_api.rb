module PublishesToPublishingApi
  extend ActiveSupport::Concern
  include HasContentId

  included do
    after_commit :publish_to_publishing_api, if: :can_publish_to_publishing_api?
    after_commit :publish_gone_to_publishing_api, on: :destroy, if: :can_publish_gone_to_publishing_api?
    define_callbacks :published, :published_gone
  end

  def can_publish_to_publishing_api?
    persisted?
  end

  def can_publish_gone_to_publishing_api?
    true
  end

  def bulk_republish_to_publishing_api_async
    if can_publish_to_publishing_api?
      Whitehall::PublishingApi.bulk_republish_async(self)
    end
  end

  def republish_to_publishing_api_async
    if can_publish_to_publishing_api?
      Whitehall::PublishingApi.republish_async(self)
    end
  end

  def publish_to_publishing_api
    run_callbacks :published do
      Whitehall::PublishingApi.patch_links(self)
      Whitehall::PublishingApi.publish(self)
    end
  end

  def publish_gone_to_publishing_api
    run_callbacks :published_gone do
      Whitehall::PublishingApi.publish_gone_async(content_id, nil, nil)
    end
  end

  def publish_gone_translation_to_publishing_api(locale)
    Whitehall::PublishingApi.publish_gone_async(content_id, nil, nil, locale)
  end
end
