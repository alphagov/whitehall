# Legacy
class TopicalEventFeaturingImageData < ApplicationRecord
  mount_uploader :file, FeaturedImageUploader, mount_on: :carrierwave_image
  include AssetData

  include ImageKind

  has_one :topical_event_featuring, inverse_of: :image
  has_many :assets,
           as: :assetable,
           inverse_of: :assetable

  validates :file, presence: true

  delegate :url, to: :file

  def requires_crop?
    false
  end

  def can_be_cropped?
    false
  end

  def attachable
    return Attachable::Null.new if topical_event_featuring.blank?

    topical_event_featuring
  end

  def attachments
    [topical_event_featuring]
  end

  def auth_bypass_ids
    []
  end   

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
