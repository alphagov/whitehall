class EditionDocumentSeries < ActiveRecord::Base
  belongs_to :edition
  belongs_to :document_series
end
