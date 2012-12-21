class SocialMediaAccount < ActiveRecord::Base
  belongs_to :socialable, polymorphic: true
  belongs_to :social_media_service

  validates :social_media_service_id, presence: true
  validates :url, presence: true, format: URI::regexp(%w(http https))

  def service_name
    social_media_service.name
  end
end
