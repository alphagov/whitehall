class DefaultNewsOrganisationImageData < ApplicationRecord
  mount_uploader :file, FeaturedImageUploader, mount_on: :carrierwave_image
  validates :file, presence: true
end
