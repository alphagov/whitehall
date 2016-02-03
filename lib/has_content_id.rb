module HasContentId
  extend ActiveSupport::Concern

  included do
    before_validation do
      self.content_id ||= SecureRandom.uuid
    end
    validates :content_id, presence: true
  end
end
