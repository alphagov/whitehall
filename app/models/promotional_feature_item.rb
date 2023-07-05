class PromotionalFeatureItem < ApplicationRecord
  VALID_YOUTUBE_URL_FORMAT = /\A(?:(?:https:\/\/youtu\.be\/)(.+)|(?:https:\/\/www.youtube\.com\/watch\?v=)(.*?)(?:&|#|$).*)\Z/

  belongs_to :promotional_feature, inverse_of: :promotional_feature_items
  has_one :organisation, through: :promotional_feature
  has_many :links, class_name: "PromotionalFeatureLink", dependent: :destroy, inverse_of: :promotional_feature_item

  validates :summary, presence: true, length: { maximum: 500 }
  validates_with ImageValidator, method: :image, size: [960, 640], if: :image_changed?
  validates :title_url, uri: true, allow_blank: true
  validate :image_or_youtube_url_is_present
  validates :youtube_video_url, format: {
    with: VALID_YOUTUBE_URL_FORMAT,
    message: "Did not match expected format, please use a https://www.youtube.com/watch?v=MSmotCRFFMc or https://youtu.be/MSmotCRFFMc URL",
    allow_blank: true,
  }
  validates :youtube_video_alt_text, presence: true, if: -> { youtube_video_url.present? }

  accepts_nested_attributes_for :links, allow_destroy: true, reject_if: ->(attributes) { attributes["url"].blank? }

  mount_uploader :image, FeaturedImageUploader

  def youtube_video_id
    return if youtube_video_url.blank?

    youtube_video_url =~ VALID_YOUTUBE_URL_FORMAT
    youtube_video_id = ::Regexp.last_match(1) || ::Regexp.last_match(2)
    raise "youtube_video_url: #{youtube_video_url} is invalid for PromotionalFeatureItem id: #{id}" if youtube_video_id.blank?

    youtube_video_id
  end

private

  def image_or_youtube_url_is_present
    errors.add(:image_or_youtube_url, "Upload either an image or add a YouTube URL") if (image.blank? && youtube_video_url.blank?) || (image.present? && youtube_video_url.present?)
  end
end
