module Edition::Scopes::FilterableByType
  extend ActiveSupport::Concern

  included do
    scope :by_type, lambda { |type|
      where(type: type.to_s)
    }

    scope :by_subtype, lambda { |type, subtype|
      merge(type.by_subtype(subtype))
    }

    scope :by_subtypes, lambda { |type, subtype_ids|
      merge(type.by_subtypes(subtype_ids))
    }

    scope :without_editions_of_type, lambda { |*edition_classes|
      where(arel_table[:type].not_in(edition_classes.map(&:name)))
    }

    scope :consultations, -> { by_type("Consultation") }
    scope :call_for_evidence, -> { by_type("CallForEvidence") }
    scope :detailed_guides, -> { by_type("DetailedGuide") }
    scope :corporate_information_pages, -> { by_type("CorporateInformationPage") }
  end
end
