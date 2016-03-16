module HasContentId
  extend ActiveSupport::Concern

  included do
    before_validation do
      self.content_id ||= SecureRandom.uuid
    end
    validates :content_id, presence: true, format: { with: /[\w\d]{8}-[\w\d]{4}-[\w\d]{4}-[\w\d]{4}-[\w\d]{12}/ }
  end
end
