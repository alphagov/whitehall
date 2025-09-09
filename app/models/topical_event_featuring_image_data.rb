class TopicalEventFeaturingImageData < ApplicationRecord
  mount_uploader :file, FeaturedImageUploader, mount_on: :carrierwave_image

  include ImageKind

  has_one :topical_event_featuring, inverse_of: :image
  has_many :assets,
           as: :assetable,
           inverse_of: :assetable

  validates :file, presence: true

  validates_with ImageValidator

  delegate :url, to: :file

  def filename
    file&.file&.filename
  end

  def asset_uploaded?
    assets.any? { |asset| asset.variant.to_sym == :original }
  end

  def republish_on_assets_ready
    if asset_uploaded?
      topical_event_featuring.topical_event.republish_to_publishing_api_async
    end
  end
end
