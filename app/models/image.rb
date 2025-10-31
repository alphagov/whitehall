class Image < ApplicationRecord
  belongs_to :image_data
  belongs_to :edition
  has_one :edition_lead_image, dependent: :destroy

  validates :alt_text, presence: true, allow_blank: true, length: { maximum: 255 }, unless: :skip_main_validation?
  validates :image_data, presence: { message: "must be present" }

  after_destroy :destroy_image_data_if_required

  accepts_nested_attributes_for :image_data

  delegate :filename, :content_type, :width, :height, :bitmap?, :svg?, :can_be_cropped?, :requires_crop?, to: :image_data

  default_scope -> { order(:id) }

  def url(*args)
    image_data.file_url(*args)
  end

  def thumbnail
    return image_data.file_url unless bitmap? && !requires_crop?

    variant = image_data.assets.find { |asset| asset.variant != "original" }&.variant&.to_sym

    return if variant.blank?

    url(variant)
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
