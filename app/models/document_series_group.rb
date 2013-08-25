class DocumentSeriesGroup < ActiveRecord::Base
  belongs_to :document_series
  has_many :memberships, class_name: 'DocumentSeriesGroupMembership',
                         order: 'document_series_group_memberships.ordering'
  has_many :documents, through: :memberships
  has_many :editions, through: :documents

  attr_accessible :body, :heading

  before_create :assign_ordering

  def assign_ordering
    peers = document_series.present? ? document_series.groups.size : 0
    self.ordering = peers + 1
  end

  def published_editions
    editions.published
  end

  def visible?
    published_editions.present?
  end
end
