module HasContentId
  extend ActiveSupport::Concern

  included do
    before_validation do
      self.content_id ||= generate_content_id
    end
    validates :content_id, presence: true, format: { with: /[\w\d]{8}-[\w\d]{4}-[\w\d]{4}-[\w\d]{4}-[\w\d]{12}/ }
  end

  def generate_content_id
    SecureRandom.uuid
  end
end
