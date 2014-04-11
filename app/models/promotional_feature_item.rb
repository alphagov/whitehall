class PromotionalFeatureItem < ActiveRecord::Base
  belongs_to :promotional_feature, inverse_of: :promotional_feature_items
  has_one :organisation, through: :promotional_feature
  has_many :links, class_name: 'PromotionalFeatureLink', dependent: :destroy, inverse_of: :promotional_feature_item

  validates :summary, presence: true, length: { maximum: 500 }
  validates_with ImageValidator, method: :image, size: [960, 640], if: :image_changed?
  validates :title_url, uri: true, allow_blank: true

  accepts_nested_attributes_for :links, allow_destroy: true, reject_if: -> attributes { attributes['url'].blank? }

  mount_uploader :image, ImageUploader
end
