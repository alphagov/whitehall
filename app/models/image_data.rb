class ImageData < ActiveRecord::Base
  has_many :images

  mount_uploader :file, DocumentImageUploader, mount_on: :carrierwave_image

  validates :file, presence: true
end