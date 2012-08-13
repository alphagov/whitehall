class EditionDocumentCollection < ActiveRecord::Base
  belongs_to :edition
  belongs_to :document_collection
end
