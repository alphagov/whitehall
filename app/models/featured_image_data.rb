class FeaturedImageData < ApplicationRecord
  mount_uploader :file, FeaturedImageUploader, mount_on: :carrierwave_image, validate_integrity: true
  include ImageKind

  belongs_to :featured_imageable, polymorphic: true

  has_many :assets,
           as: :assetable,
           inverse_of: :assetable

  validate :file_must_be_valid
  validates :featured_imageable, presence: true

  validates_with ImageValidator

  delegate :url, to: :file

  def filename
    file&.file&.filename
  end

  def all_asset_variants_uploaded?
    asset_variants = assets.map(&:variant).map(&:to_sym)
    required_variants = FeaturedImageUploader.versions.keys.push(:original)

    return false if (required_variants - asset_variants).any?

    assets_match_updated_image_filename
  end

  def republish_on_assets_ready
    if all_asset_variants_uploaded?
      logger.info("FeaturedImageData #{id} (#{featured_imageable_type}:#{featured_imageable_id}) republishing after all asset variants are uploaded")
      featured_imageable.republish_to_publishing_api_async if featured_imageable.respond_to? :republish_to_publishing_api_async
      Whitehall::PublishingApi.republish_document_async(featured_imageable.document) if featured_imageable.is_a?(Edition)
      featured_imageable.republish_dependent_documents if featured_imageable.respond_to? :republish_dependent_documents
    end
  end

private
  def file_must_be_valid
    if file.blank? && !errors[:file].present?
      errors.add(:file, activerecord.errors.models.attachment_data.attributes.file.blank)
    end
  end

  def assets_match_updated_image_filename
    assets.all? { |asset| asset.filename.include?(filename) } if filename
  end
end
