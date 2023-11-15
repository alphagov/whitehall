class FeaturedImageData < ApplicationRecord
  mount_uploader :file, FeaturedImageUploader, mount_on: :carrierwave_image

  belongs_to :featured_imageable, polymorphic: true

  has_many :assets,
           as: :assetable,
           inverse_of: :assetable

  validates :file, presence: true
  validates :featured_imageable, presence: true

  validates_with ImageValidator, size: [960, 640]

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
      featured_imageable.publish_to_publishing_api_async if featured_imageable.respond_to? :publish_to_publishing_api_async
      featured_imageable.republish_dependent_documents if featured_imageable.respond_to? :republish_dependent_documents
    end
  end
end
