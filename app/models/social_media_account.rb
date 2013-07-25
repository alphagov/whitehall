class SocialMediaAccount < ActiveRecord::Base
  belongs_to :socialable, polymorphic: true
  belongs_to :social_media_service

  validates :social_media_service_id, presence: true
  validates :url, presence: true, uri: true
  validates :title, length: { maximum: 255 }

  def service_name
    social_media_service.name
  end

  def display_name
    title.present? ? title : service_name
  end
end
