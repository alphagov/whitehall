class DocumentSeries < ActiveRecord::Base
  belongs_to :organisation

  has_many :editions, through: :edition_document_series, order: 'publication_date desc'
  has_many :edition_document_series

  validates_with SafeHtmlValidator
  validates :name, presence: true

  before_destroy { |dc| dc.destroyable? }

  extend FriendlyId
  friendly_id

  def published_editions
    editions.published
  end

  def published_publications
    published_editions.where(type: Publication.name)
  end

  def published_statistical_data_sets
    published_editions.where(type: StatisticalDataSet.name)
  end

  def scheduled_publications
    editions.scheduled.where(type: Publication.name)
  end

  def scheduled_statistical_data_sets
    editions.scheduled.where(type: StatisticalDataSet.name)
  end

  protected

  def destroyable?
    editions.empty?
  end
end
