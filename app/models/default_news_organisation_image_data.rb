# == Schema Information
#
# Table name: default_news_organisation_image_data
#
#  id                :integer          not null, primary key
#  carrierwave_image :string(255)
#  created_at        :datetime
#  updated_at        :datetime
#

class DefaultNewsOrganisationImageData < ActiveRecord::Base
  mount_uploader :file, ImageUploader, mount_on: :carrierwave_image
  validates :file, presence: true
end
