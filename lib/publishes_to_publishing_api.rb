module PublishesToPublishingApi
  extend ActiveSupport::Concern

  included do
    before_validation :generate_content_id, on: :create
    validates :content_id, presence: true
    after_commit :publish_to_publishing_api, if: :persisted?
  end


  def generate_content_id
    self.content_id ||= SecureRandom.uuid
  end

  def publish_to_publishing_api
    Whitehall::PublishingApi.publish(self)
  end
end
