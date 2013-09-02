# == Schema Information
#
# Table name: social_media_services
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class SocialMediaService < ActiveRecord::Base
  validates :name, presence: true, uniqueness: true
end
