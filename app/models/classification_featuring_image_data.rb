class ClassificationFeaturingImageData < ActiveRecord::Base
  mount_uploader :file, ImageUploader, mount_on: :carrierwave_image
  validates :file, presence: true

  validate :image_must_be_960px_by_640px, if: :image_changed?

  private

  def image_changed?
    changes["carrierwave_image"].present?
  end

  def image_must_be_960px_by_640px
    image = file && file.path && MiniMagick::Image.open(file.path)
    unless image.nil? || (image[:width] == 960 && image[:height] == 640)
      errors.add(:image, "must be 960px wide and 640px tall")
    end
  end
end