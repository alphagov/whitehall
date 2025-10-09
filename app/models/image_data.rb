require "mini_magick"

class ImageData < ApplicationRecord
  attr_accessor :validate_on_image

  include ImageKind

  SVG_CONTENT_TYPE = "image/svg+xml".freeze

  has_many :images
  has_many :assets,
           as: :assetable,
           inverse_of: :assetable

  mount_uploader :file, ImageUploader, mount_on: :carrierwave_image

  validate :file_is_not_blank
  validate :filename_is_unique

  delegate :content_type, to: :file

  before_save :recreate_cropped_assets, if: :crop_data_changed?

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

    "#{crop_data['width']}x#{crop_data['height']}+#{crop_data['x']}+#{crop_data['y']}"
  end

  def requires_crop?
    too_large? && crop_data.blank?
  end

  def can_be_cropped?
    too_large? && bitmap?
  end

  def original_uploaded?
    assets.map(&:variant).map(&:to_sym).include?(:original)
  end

  def all_asset_variants_uploaded?
    asset_variants = assets.map(&:variant).map(&:to_sym)
    required_variants = file.active_version_names + [:original]

    (required_variants - asset_variants).empty?
  end

  def svg?
    content_type == SVG_CONTENT_TYPE
  end

  # if there is no height, we can assume that this
  # image was uploaded before the changes to save
  # the dimensions on upload which means it must have
  # had a valid height to have been saved
  def height
    (dimensions || {})["height"] || image_kind_config.valid_height
  end

  # if there is no width, we can assume that this
  # image was uploaded before the changes to save
  # the dimensions on upload which means it must have
  # had a valid width to have been saved
  def width
    (dimensions || {})["width"] || image_kind_config.valid_width
  end

  def too_large?
    return unless respond_to?(:image_kind_config)

    target_width = image_kind_config.valid_width
    target_height = image_kind_config.valid_height

    width > target_width || height > target_height
  end

private

  def file_is_not_blank
    errors.add(:file, :blank) if file.blank? && errors[:file].blank?
  end

  def filename_is_unique
    return if validate_on_image.blank? || file.blank?

    image = validate_on_image
    edition = validate_on_image.edition

    if edition.images.excluding(image).joins(:image_data).exists?(["image_data.carrierwave_image = ?", filename])
      errors.add(:file, message: "name is not unique. All your file names must be different. Do not use special characters to create another version of the same file name.")
    end
  end

  def crop_data_changed?
    too_large? && changes["crop_data"].present?
  end

  def recreate_cropped_assets
    file.download! file.url

    assets.each do |asset|
      unless asset.original?
        AssetManager::AssetDeleter.call(asset.asset_manager_id)
        asset.delete
      end
    end

    file.store!
  rescue CarrierWave::DownloadError
    errors.add(:file, message: "could not crop file. Please try again.")
  end

  def image_changed?
    # if the dimensions have changed then
    # an image with the same name has been
    # reuploaded and we need to revalidate
    changes["carrierwave_image"].present? || changes["dimensions"].present?
  end
end
