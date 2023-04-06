require "mini_magick"

class ImageData < ApplicationRecord
  attr_accessor :validate_on_image

  VALID_WIDTH = 960
  VALID_HEIGHT = 640

  has_many :images

  mount_uploader :file, ImageUploader, mount_on: :carrierwave_image

  validates :file, presence: true
  validates_with ImageValidator, size: [VALID_WIDTH, VALID_HEIGHT]
  validate :filename_is_unique

  delegate :width, :height, to: :dimensions
  delegate :content_type, to: :file

  def filename
    file.file.filename
  end

  def auth_bypass_ids
    images
      .joins(:edition)
      .where("editions.state in (?)", Edition::PRE_PUBLICATION_STATES)
      .map { |e| e.edition.auth_bypass_id }
      .uniq
  end

  def bitmap?
    content_type !~ /svg/
  end

private

  Dimensions = Struct.new(:width, :height)

  def dimensions
    @dimensions ||= if valid?
                      # Whitehall doesn't store local copies of original images. Once they've been
                      # uploaded to Asset Manager, we can't expect them to exist locally again.
                      # But since every uploaded image has to be these exact dimensions, we can
                      # be confident a valid image (either freshly uploaded, or already persisted)
                      # will be these exact dimensions.
                      Dimensions.new(VALID_WIDTH, VALID_HEIGHT)
                    else
                      image = MiniMagick::Image.open file.path
                      Dimensions.new(image[:width], image[:height])
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
