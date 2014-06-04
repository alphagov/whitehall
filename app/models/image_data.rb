require 'mini_magick'

class ImageData < ActiveRecord::Base
  has_many :images

  mount_uploader :file, ImageUploader, mount_on: :carrierwave_image

  validates :file, presence: true
  validates_with ImageValidator, size: [50,50]
end
