class EditionOrganisationImageData < ActiveRecord::Base
  mount_uploader :file, EditionOrganisationImageUploader, mount_on: :carrierwave_image
  validates :file, presence: true
end