class DefaultNewsOrganisationImageData < ApplicationRecord
  mount_uploader :file, FeaturedImageUploader, mount_on: :carrierwave_image
  validates :file, presence: true, if: :image_changed?

  has_many :assets,
           as: :assetable,
           inverse_of: :assetable

  def image_changed?
    changes["carrierwave_image"].present?
  end
end
