module PublishesToPublishingApi
  extend ActiveSupport::Concern

  included do
    before_validation :generate_content_id, on: :create
    validates :content_id, presence: true
    after_commit :publish_to_publishing_api, if: :can_publish_to_publishing_api?
  end


  def generate_content_id
    self.content_id ||= SecureRandom.uuid
  end

  def can_publish_to_publishing_api?
    persisted?
  end

  def publish_to_publishing_api
    Whitehall::PublishingApi.publish_async(self)
  end
end
