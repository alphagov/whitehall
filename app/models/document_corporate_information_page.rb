class DocumentCorporateInformationPage < ApplicationRecord
  belongs_to :corporate_information_page, foreign_key: :edition_id, class_name: "Edition"
  belongs_to :owning_organisation_document, inverse_of: :document_corporate_information_pages, foreign_key: :owning_document_id, class_name: "Document"

  validates :corporate_information_page, :owning_organisation_document, presence: true
end
