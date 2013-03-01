class DocumentSeries < ActiveRecord::Base
  include Rails.application.routes.url_helpers
  include Searchable

  belongs_to :organisation

  has_many :editions, through: :edition_document_series, order: 'publication_date desc'
  has_many :edition_document_series

  validates_with SafeHtmlValidator
  validates :name, presence: true

  before_destroy { |dc| dc.destroyable? }

  searchable title: :name,
             link: :search_link,
             content: :description

  extend FriendlyId
  friendly_id

  def search_link
    organisation_document_series_path(organisation, slug)
  end

  def published_editions
    editions.published
  end

  def published_publications
    published_editions.where(type: Publication.name)
  end

  def published_statistical_data_sets
    published_editions.where(type: StatisticalDataSet.name)
  end

  def published_consultations
    published_editions.where(type: Consultation.name)
  end

  def published_speeches
    published_editions.where(type: Speech.name)
  end

  def published_detailed_guides
    published_editions.where(type: DetailedGuide.name)
  end

  def published_case_studies
    published_editions.where(type: CaseStudy.name)
  end

  def published_news_articles
    published_editions.where(type: NewsArticle.name)
  end

  def scheduled_editions
    editions.scheduled
  end

  protected

  def destroyable?
    editions.empty?
  end
end
