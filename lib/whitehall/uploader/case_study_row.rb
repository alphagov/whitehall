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
      Finders::EditionFinder.new(DocumentCollection, @logger, @line_number).find(*fields(1..4, 'document_collection_#'))
    end

    def related_editions
      Finders::EditionFinder.new(Policy, @logger, @line_number).find(*fields(1..4, 'policy_#'))
    end

    def first_published_at
      Parsers::DateParser.parse(row['first_published'], @logger, @line_number)
    end

    def attributes
      {
        title: title,
        summary: summary,
        body: body,
        lead_organisations: lead_organisations,
        related_editions: related_editions,
        first_published_at: first_published_at
      }
    end
  end
end
