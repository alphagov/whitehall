module Whitehall::Uploader
  class CaseStudyRow < Row

    def self.validator
      super
        .required("first_published")
        .ignored("ignore_*")
        .multiple("document_collection_#", 0..4)
    end

    def document_collections
      fields(1..4, 'document_collection_#').compact.reject(&:blank?)
    end

  protected
    def attribute_keys
      super + [
        :first_published_at,
        :lead_organisations,
      ]
    end
  end
end
