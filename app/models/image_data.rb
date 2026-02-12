require "mini_magick"

class ImageData < ApplicationRecord
  attr_accessor :image, :validate_on_image

  store_accessor :dimensions, %i[width height]
  store_accessor :crop_data, %i[x y width height], prefix: true

  before_create :set_dimensions

  include Replaceable
  include ImageKind

  SVG_CONTENT_TYPE = "image/svg+xml".freeze

  has_many :images
  has_many :assets,
           as: :assetable,
           inverse_of: :assetable

  mount_uploader :file, ImageUploader, mount_on: :carrierwave_image

  validates :file, presence: { message: "cannot be uploaded. Choose a valid JPEG, PNG, SVG or GIF." }
  validate :filename_is_unique

  delegate :url, :content_type, to: :file

  def filename
    file&.file&.filename
  end

  def auth_bypass_ids
    images
      .filter { |image| Edition::PRE_PUBLICATION_STATES.include? image.edition.state }
      .map { |image| image.edition.auth_bypass_id }
      .uniq
  end

  def bitmap?
    content_type !~ /svg/
  end

  def crop_data_to_params(version_width, version_height)
    return if crop_data.blank?

    set_dimensions if dimensions.blank?

    return if version_width == width && version_height == height

    scale = crop_data_width.to_f / image_kind_config.valid_width

    new_x = (crop_data_x.to_f + (crop_data_width.to_f / 2)) - ((version_width.to_f * scale) / 2)
    new_y = (crop_data_y.to_f + (crop_data_height.to_f / 2)) - ((version_height.to_f * scale) / 2)

    "#{version_width * scale}x#{version_height * scale}+#{new_x}+#{new_y}"
  end

  def requires_crop?
    too_large? && crop_data.blank?
  end

  def can_be_cropped?
    bitmap?
  end

  def original_uploaded?
    assets.find_by(variant: "original").try(:asset_manager_id)
  end

  def all_asset_variants_uploaded?
    asset_variants = assets.map(&:variant).map(&:to_sym)
    required_variants = file.active_version_names + [:original]

    (required_variants - asset_variants).empty?
  end

  def svg?
    content_type == SVG_CONTENT_TYPE
  end

  def too_large?
    return if dimensions.blank?

    target_width = image_kind_config.valid_width
    target_height = image_kind_config.valid_height

    width > target_width || height > target_height
  end

private

  def set_dimensions
    if file&.file && bitmap?
      begin
        self.width = file.width
        self.height = file.height
      rescue MiniMagick::Error, MiniMagick::Invalid
        raise CarrierWave::IntegrityError, "could not be read. The file may not be an image or may be corrupt"
      end
    end
  end

  def filename_is_unique
    return if validate_on_image.blank? || file.blank?

    image = validate_on_image
    edition = validate_on_image.edition

    if edition.images.excluding(image).joins(:image_data).exists?(["image_data.carrierwave_image = ?", filename])
      errors.add(:file, message: "name is not unique. All your file names must be different. Do not use special characters to create another version of the same file name.")
    end
  end
end
