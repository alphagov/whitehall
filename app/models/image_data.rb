# == Schema Information
#
# Table name: image_data
#
#  id                :integer          not null, primary key
#  carrierwave_image :string(255)
#  created_at        :datetime
#  updated_at        :datetime
#

require 'mini_magick'

class ImageData < ActiveRecord::Base
  has_many :images

  mount_uploader :file, ImageUploader, mount_on: :carrierwave_image

  validates :file, presence: true
  validate :image_must_be_960px_by_640px

  def image_must_be_960px_by_640px
    if file.path
      errors.add(:file, 'must be 960px wide and 640px tall') unless ImageSizeChecker.new(file.path).size_is?(960, 640)
    end
  end
end
