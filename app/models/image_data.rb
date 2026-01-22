require "mini_magick"

class ImageData < ApplicationRecord
  attr_accessor :image, :validate_on_image

  store_accessor :dimensions, %i[width height]
  store_accessor :crop_data, %i[x y width height], prefix: true
  after_initialize :dimensions_from_config

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

  def crop_data_to_params
    return if crop_data.blank?

    "#{crop_data_width}x#{crop_data_height}+#{crop_data_x}+#{crop_data_y}"
  end

  def requires_crop?
    too_large? && crop_data.blank?
  end

  def can_be_cropped?
    too_large? && bitmap?
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
    return unless respond_to?(:image_kind_config) && dimensions.present?

    target_width = image_kind_config.valid_width
    target_height = image_kind_config.valid_height

    width > target_width || height > target_height
  end

private

  def dimensions_from_config
    return unless bitmap? && respond_to?(:image_kind_config)

    # if no saved dimensions image created when
    # cropped images were saved with height and
    # and width of the associated image config
    self.height ||= image_kind_config.valid_height
    self.width ||= image_kind_config.valid_width
  end

  def filename_is_unique
    return if validate_on_image.blank? || file.blank?

    image = validate_on_image
    edition = validate_on_image.edition

    if edition.images.excluding(image).joins(:image_data).exists?(["image_data.carrierwave_image = ?", filename])
      errors.add(:file, message: "name is not unique. All your file names must be different. Do not use special characters to create another version of the same file name.")
    end
  end

  def image_changed?
    changes["carrierwave_image"].present?
  end
end
