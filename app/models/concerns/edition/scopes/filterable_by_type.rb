module Edition::Scopes::FilterableByType
  extend ActiveSupport::Concern

  included do
    scope :consultations, -> { where(type: "Consultation") }
    scope :call_for_evidence, -> { where(type: "CallForEvidence") }
    scope :detailed_guides, -> { where(type: "DetailedGuide") }
    scope :corporate_information_pages, -> { where(type: "CorporateInformationPage") }
  end
end
