class PromotionalFeatureItem < ActiveRecord::Base
  belongs_to :promotional_feature, inverse_of: :promotional_feature_items
  has_one :organisation, through: :promotional_feature

  validates :summary, presence: true, length: { maximum: 500 }
  validates :image, :image_alt_text, presence: true
  validate :image_must_be_960px_by_640px, if: :image_changed?

  mount_uploader :image, ImageUploader

  def image_must_be_960px_by_640px
    if image.path
      errors.add(:image, 'must be 960px wide and 640px tall') unless ImageSizeChecker.new(image.path).size_is?(960, 640)
    end
  end
end
