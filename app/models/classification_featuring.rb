class ClassificationFeaturing < ActiveRecord::Base
  belongs_to :edition, inverse_of: :classification_featurings
  belongs_to :classification, inverse_of: :classification_featurings
  belongs_to :image, class_name: 'ClassificationFeaturingImageData', foreign_key: :classification_featuring_image_data_id

  accepts_nested_attributes_for :image, reject_if: :all_blank

  validates :image, :alt_text, presence: true

  validates :edition, :classification, :ordering, presence: true

  validates :edition_id, uniqueness: { scope: :classification_id }
end
