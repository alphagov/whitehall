# == Schema Information
#
# Table name: classification_featuring_image_data
#
#  id                :integer          not null, primary key
#  carrierwave_image :string(255)
#  created_at        :datetime
#  updated_at        :datetime
#

class ClassificationFeaturingImageData < ActiveRecord::Base
  mount_uploader :file, ImageUploader, mount_on: :carrierwave_image

  validates :file, presence: true, if: :image_changed?
  validate :image_must_be_960px_by_640px, if: :image_changed?

  private

  def image_changed?
    changes["carrierwave_image"].present?
  end

  def image_must_be_960px_by_640px
    if file.path
      errors.add(:file, 'must be 960px wide and 640px tall') unless ImageSizeChecker.new(file.path).size_is?(960, 640)
    end
  end
end
