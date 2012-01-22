class Featuring < ActiveRecord::Base
  mount_uploader :image, FeaturingImageUploader, mount_on: :carrierwave_image
  validates :image, presence: true
  has_one :news_article
end
