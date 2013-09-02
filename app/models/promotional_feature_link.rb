# == Schema Information
#
# Table name: promotional_feature_links
#
#  id                          :integer          not null, primary key
#  promotional_feature_item_id :integer
#  url                         :string(255)
#  text                        :string(255)
#  created_at                  :datetime
#  updated_at                  :datetime
#

class PromotionalFeatureLink < ActiveRecord::Base
  belongs_to :promotional_feature_item, inverse_of: :links

  validates :url, presence: true, uri: true
  validates :text, :promotional_feature_item, presence: true
end
