class PromotionalFeatureLink < ActiveRecord::Base
  belongs_to :promotional_feature_item, inverse_of: :links

  validates :url, presence: true, uri: true
  validates :text, :promotional_feature_item, presence: true
end
