require "mini_magick"

class ImageData < ApplicationRecord
  has_many :images

  mount_uploader :file, ImageUploader, mount_on: :carrierwave_image

  validates :file, presence: true
  validates_with ImageValidator, size: [960, 640]

  def auth_bypass_ids
    images
      .joins(:edition)
      .where("editions.state in (?)", Edition::PRE_PUBLICATION_STATES)
      .map { |e| e.edition.auth_bypass_id }
      .uniq
  end
end
