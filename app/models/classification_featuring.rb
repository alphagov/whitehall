# == Schema Information
#
# Table name: classification_featurings
#
#  id                                     :integer          not null, primary key
#  edition_id                             :integer
#  classification_id                      :integer
#  created_at                             :datetime
#  updated_at                             :datetime
#  ordering                               :integer
#  classification_featuring_image_data_id :integer
#  alt_text                               :string(255)
#

class ClassificationFeaturing < ActiveRecord::Base
  belongs_to :edition
  belongs_to :classification
  belongs_to :image, class_name: 'ClassificationFeaturingImageData', foreign_key: :classification_featuring_image_data_id

  accepts_nested_attributes_for :image, reject_if: :all_blank

  validates :image, :alt_text, presence: true

  validates :edition, :classification, :ordering, presence: true

  validates :edition_id, uniqueness: {scope: :classification_id}
end
