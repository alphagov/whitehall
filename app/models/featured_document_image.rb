class FeaturedDocumentImage < ActiveRecord::Base
  mount_uploader :image, FeaturedDocumentImageUploader, mount_on: :carrierwave_image
  validates :image, presence: true
  has_one :news_article
end
