class DocumentSeriesGroup < ActiveRecord::Base
  belongs_to :document_series
  has_many :memberships, class_name: 'DocumentSeriesGroupMembership',
                         order: 'document_series_group_memberships.ordering',
                         dependent: :destroy
  has_many :documents, through: :memberships
  has_many :editions, through: :documents

  attr_accessible :body, :heading

  validates :heading, presence: true, uniqueness: { scope: :document_series_id }

  before_create :assign_ordering

  def self.visible
    includes(:editions).where('editions.state = ?', 'published')
  end

  def self.default_attributes
    { heading: 'Documents' }
  end

  def assign_ordering
    peers = document_series.present? ? document_series.groups.size : 0
    self.ordering = peers + 1
  end

  def published_editions
    editions.published.in_reverse_chronological_order
  end

  def latest_editions
    associations = { latest_edition: [:organisations, :translations] }
    editions = documents.includes(associations).map(&:latest_edition)
    editions.compact.sort_by { |edition| - edition.public_timestamp.to_i }
  end

  def visible?
    published_editions.present?
  end
end
