class DocumentSeries < ActiveRecord::Base
  include Searchable
  include SimpleWorkflow

  belongs_to :organisation

  has_many :groups, class_name: 'DocumentSeriesGroup', order: 'document_series_groups.ordering'
  has_many :documents, through: :groups
  has_many :editions, through: :documents

  validates_with SafeHtmlValidator
  validates :name, presence: true, length: { maximum: 255 }
  validates :summary, presence: true, length: { maximum: 255 }
  validates :description, length: { maximum: (64.kilobytes - 1) }

  searchable title: :name,
             link: :search_link,
             content: :description_without_markup,
             description: :summary,
             slug: :slug

  extend FriendlyId
  friendly_id

  def published_editions
    editions.published.in_reverse_chronological_order
  end

  def scheduled_editions
    editions.scheduled
  end

  def search_link
    Whitehall.url_maker.organisation_document_series_path(organisation, slug)
  end

  def description_without_markup
    Govspeak::Document.new(description).to_text
  end

  def destroyable?
    published_editions.empty?
  end
end
