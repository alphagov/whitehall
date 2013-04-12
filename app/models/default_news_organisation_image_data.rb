class DefaultNewsOrganisationImageData < ActiveRecord::Base
  mount_uploader :file, ImageUploader, mount_on: :carrierwave_image
  validates :file, presence: true
end
