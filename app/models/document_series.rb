class DocumentSeries < ActiveRecord::Base
  include Searchable
  include SimpleWorkflow

  belongs_to :organisation

  has_many :editions, through: :edition_document_series

  has_many :published_editions,
            through: :edition_document_series,
            conditions: { state: "published" },
            order: 'publication_date desc',
            source: :edition

  has_many :edition_document_series

  validates_with SafeHtmlValidator
  validates :name, presence: true, length: { maximum: 255 }
  validates :summary, presence: true, length: { maximum: 255 }
  validates :description, length: { maximum: (64.kilobytes - 1) }

  searchable title: :name,
             link: :search_link,
             content: :description,
             description: :summary

  extend FriendlyId
  friendly_id

  def search_link
    Whitehall.url_maker.organisation_document_series_path(organisation, slug)
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

  def destroyable?
    published_editions.empty?
  end
end
