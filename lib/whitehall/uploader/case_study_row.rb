module Whitehall::Uploader
  class CaseStudyRow < Row

    def self.validator
      super
        .required("first_published")
        .ignored("ignore_*")
        .multiple("policy_#", 0..4)
        .multiple("document_collection_#", 0..4)
    end

    def document_collections
      fields(1..4, 'document_collection_#').compact.reject(&:blank?)
    end

    def related_editions
      Finders::EditionFinder.new(Policy, @logger, @line_number).find(*fields(1..4, 'policy_#'))
    end

  protected
    def attribute_keys
      super + [
        :first_published_at,
        :lead_organisations,
        :related_editions
      ]
    end
  end
end
