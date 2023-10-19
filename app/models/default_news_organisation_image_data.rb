class DefaultNewsOrganisationImageData < ApplicationRecord
  has_many :assets,
           as: :assetable,
           inverse_of: :assetable

  mount_uploader :file, FeaturedImageUploader, mount_on: :carrierwave_image
  validates :file, presence: true
end
