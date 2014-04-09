class ClassificationFeaturing < ActiveRecord::Base
  belongs_to :edition, inverse_of: :classification_featurings
  belongs_to :classification, inverse_of: :classification_featurings
  belongs_to :image, class_name: 'ClassificationFeaturingImageData', foreign_key: :classification_featuring_image_data_id

  accepts_nested_attributes_for :image, reject_if: :all_blank

  validates :image, :alt_text, presence: true

  validates :classification, :ordering, presence: true
  validates :offsite_title, :offsite_summary, presence: true, if: :offsite?
  validates :offsite_url, presence: true, uri: true, if: :offsite?
  validates :edition_id, uniqueness: { scope: :classification_id }, unless: :offsite?

  def title
    offsite_title || edition.title
  end

  def summary
    offsite_summary || edition.summary
  end

  def url
    offsite_url || Whitehall.url_maker.public_document_path(edition)
  end

  def offsite?
    edition.nil?
  end
end
