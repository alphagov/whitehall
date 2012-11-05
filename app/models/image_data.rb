require 'mini_magick'

class ImageData < ActiveRecord::Base
  has_many :images

  mount_uploader :file, ImageUploader, mount_on: :carrierwave_image

  validates :file, presence: true
  validate :image_must_be_960px_by_640px

  def image_must_be_960px_by_640px
    image = file.path && MiniMagick::Image.open(file.path)
    unless image.nil? || (image[:width] == 960 && image[:height] == 640)
      errors.add(:file, "must be 960px wide and 640px tall")
    end
  end
end