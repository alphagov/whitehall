class FeaturedImageData < ApplicationRecord
  mount_uploader :file, FeaturedImageUploader, mount_on: :carrierwave_image

  has_many :assets,
           as: :assetable,
           inverse_of: :assetable

  validates :file, presence: true
  validates_with ImageValidator, size: [960, 640]
end
