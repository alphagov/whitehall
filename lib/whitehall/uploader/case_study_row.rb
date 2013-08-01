module Whitehall::Uploader
  class CaseStudyRow < Row

    def self.validator
      super
        .required("first_published")
        .ignored("ignore_*")
        .multiple("policy_#", 0..4)
        .multiple("document_series_#", 0..4)
    end

    def document_series
      Finders::SluggedModelFinder.new(DocumentSeries, @logger).find(fields(1..4, 'document_series_#'))
    end

    def related_editions
      Finders::PoliciesFinder.find(*fields(1..4, 'policy_#'), @logger, @line_number)
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
        document_series: document_series,
        related_editions: related_editions,
        first_published_at: first_published_at
      }
    end
  end
end
