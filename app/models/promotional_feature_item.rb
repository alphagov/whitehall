class PromotionalFeatureItem < ApplicationRecord
  belongs_to :promotional_feature, inverse_of: :promotional_feature_items
  has_one :organisation, through: :promotional_feature
  has_many :links, class_name: "PromotionalFeatureLink", dependent: :destroy, inverse_of: :promotional_feature_item

  validates :summary, presence: true, length: { maximum: 500 }
  validates_with ImageValidator, method: :image, size: [960, 640], if: :image_changed?
  validates :title_url, uri: true, allow_blank: true
  validate :image_or_youtube_url_is_present

  accepts_nested_attributes_for :links, allow_destroy: true, reject_if: ->(attributes) { attributes["url"].blank? }

  mount_uploader :image, ImageUploader

private

  def image_or_youtube_url_is_present
    errors.add(:base, "Upload either an image or add a YouTube URL") if (image.blank? && youtube_video_url.blank?) || (image.present? && youtube_video_url.present?)
  end
end
