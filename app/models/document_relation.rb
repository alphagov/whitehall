class DocumentRelation < ActiveRecord::Base
  belongs_to :document
  belongs_to :related_document, class_name: "Document"
end
