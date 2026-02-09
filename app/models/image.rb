class Image < ApplicationRecord
  belongs_to :image_data
  belongs_to :edition
  has_one :edition_lead_image, dependent: :destroy

  validates :image_data, presence: { message: "must be present" }
  validates :usage, presence: { message: "must be specified" }

  after_destroy :destroy_image_data_if_required

  accepts_nested_attributes_for :image_data

  delegate :filename, :content_type, :width, :height, :bitmap?, :svg?, :can_be_cropped?, :requires_crop?, :image_kind, to: :image_data

  default_scope -> { order(:id) }

  def url(*args)
    image_data.file_url(*args)
  end

  def embed_url
    return unless image_data.respond_to?(:image_kind_config)

    embed_version = image_data.image_kind_config.embed_version

    return url if embed_version.blank? || !image_data.all_asset_variants_uploaded?

    url(embed_version.to_sym) || url
  end

  def thumbnail
    return image_data.file_url unless bitmap? && !requires_crop?

    variant = image_data.assets.find { |asset| asset.variant != "original" }&.variant&.to_sym

    return if variant.blank?

    url(variant)
  end

  def can_be_lead_image?
    !requires_crop? && bitmap?
  end

  def can_be_used?
    !bitmap? || !requires_crop?
  end

  def publishing_api_details
    {
      type: usage,
      url:,
      caption:,
      content_type:,
    }
  end

private

  def destroy_image_data_if_required
    if image_data && Image.where(image_data_id: image_data.id).empty?
      image_data.destroy!
    end
  end

  def skip_main_validation?
    edition && edition.skip_main_validation?
  end
end
