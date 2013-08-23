class DocumentSeriesGroup < ActiveRecord::Base
  belongs_to :document_series
  has_many :memberships, class_name: 'DocumentSeriesGroupMembership',
                         order: 'document_series_group_memberships.ordering'
  has_many :documents, through: :memberships

  attr_accessible :body, :heading

  before_create :assign_ordering

  def assign_ordering
    self.ordering = document_series.groups.size + 1
  end
end
