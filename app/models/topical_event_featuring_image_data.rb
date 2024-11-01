class TopicalEventFeaturingImageData < ApplicationRecord
  include ImageKind

  mount_uploader :file, FeaturedImageUploader, mount_on: :carrierwave_image

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

  def all_asset_variants_uploaded?
    asset_variants = assets.map(&:variant).map(&:to_sym)
    required_variants = FeaturedImageUploader.versions.keys.push(:original)

    (required_variants - asset_variants).empty?
  end

  def republish_on_assets_ready
    if all_asset_variants_uploaded?
      topical_event_featuring.topical_event.republish_to_publishing_api_async
    end
  end
end
