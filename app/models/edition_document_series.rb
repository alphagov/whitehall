class EditionDocumentSeries < ActiveRecord::Base
  belongs_to :edition
  belongs_to :document_series

  validates_uniqueness_of :edition_id, scope: :document_series_id
end
