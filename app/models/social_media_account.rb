# == Schema Information
#
# Table name: social_media_accounts
#
#  id                      :integer          not null, primary key
#  socialable_id           :integer
#  social_media_service_id :integer
#  url                     :string(255)
#  created_at              :datetime
#  updated_at              :datetime
#  socialable_type         :string(255)
#  title                   :string(255)
#

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
