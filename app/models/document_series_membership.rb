class DocumentSeriesMembership < ActiveRecord::Base
  belongs_to :document_series
  belongs_to :document
end
