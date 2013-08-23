class DocumentSeries < ActiveRecord::Base
  include Searchable
  include SimpleWorkflow

  belongs_to :organisation

  has_many :document_series_memberships
  has_many :groups, class_name: 'DocumentSeriesGroup', order: 'document_series_groups.ordering'
  has_many :documents, through: :document_series_memberships, inverse_of: :document_series  do
    # This stops duplicate joins being created when appending existing docs to a series.
    def <<(*items)
      super(items - proxy_association.owner.documents)
    end
  end
  has_many :editions, through: :documents

  # NOTE: These two associations are here so that front-end pages will
  # still display pubished editions during the period between the app
  # being deployed and the data migration being run.
  # They should be removed once the data migration has run.
  has_many :legacy_published_editions,
            through: :edition_document_series,
            conditions: { state: "published" },
            order: 'first_published_at desc',
            source: :edition
  has_many :edition_document_series

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

  def latest_editions
    documents.map(&:latest_edition).compact.sort_by {|edition| edition.public_timestamp.to_i }.reverse
  end

  # NOTE: This method is currently shimmed so that it falls back to the legacy
  # association if no editions are found through the new one. It can be simplified
  # once the feature is deployed and the data migration has been run.
  def published_editions
    editions_through_new_scope = editions.published.in_reverse_chronological_order
    editions_through_new_scope.any? ? editions_through_new_scope : legacy_published_editions
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
