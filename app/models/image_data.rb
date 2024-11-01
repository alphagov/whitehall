require "mini_magick"

class ImageData < ApplicationRecord
  include ImageKind

  attr_accessor :validate_on_image

  SVG_CONTENT_TYPE = "image/svg+xml".freeze

  has_many :images
  has_many :assets,
           as: :assetable,
           inverse_of: :assetable

  mount_uploader :file, ImageUploader, mount_on: :carrierwave_image

  validates :valid_width, presence: true
  validates :valid_height, presence: true
  validates :file, presence: { message: "cannot be uploaded. Choose a valid JPEG, PNG, SVG or GIF." }
  validates_with ImageValidator, if: :image_changed?
  validate :filename_is_unique

  delegate :width, :height, to: :dimensions
  delegate :content_type, to: :file

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

  def all_asset_variants_uploaded?
    asset_variants = assets.map(&:variant).map(&:to_sym)
    required_variants = bitmap? ? ImageUploader.versions.keys.push(:original) : [Asset.variants[:original].to_sym]

    (required_variants - asset_variants).empty?
  end

  def svg?
    content_type == SVG_CONTENT_TYPE
  end

private

  def dimensions
    @dimensions ||= if valid?
                      # Whitehall doesn't store local copies of original images. Once they've been
                      # uploaded to Asset Manager, we can't expect them to exist locally again.
                      # But since every uploaded image has to have valid dimensions, we can
                      # be confident a valid image (either freshly uploaded, or already persisted)
                      # will be these exact dimensions.
                      Edition::Images::Dimensions.new(width: valid_width, height: valid_height)
                    else
                      image = MiniMagick::Image.open file.path
                      Edition::Images::Dimensions.new(width: image[:width], height: image[:height])
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

  def image_changed?
    changes["carrierwave_image"].present?
  end
end
