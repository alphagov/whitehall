module Whitehall::DocumentFilter
  class Result
    ACCESSORS = %w{title description indexable_content attachments
      format display_type link id search_format_types
      relevant_to_local_government presentation_format
      humanized_format}
    ACCESSORS.each do |attribute_name|
      define_method attribute_name.to_sym do
        @doc[attribute_name.to_s]
      end
    end

    def initialize(doc, all_orgs, all_topics, all_doc_series, all_operation_fields)
      @doc = doc
      @all_orgs = all_orgs
      @all_topics = all_topics
      @all_doc_series = all_doc_series
      @all_operation_fields = all_operation_fields
    end

    def type
      format
    end

    def public_timestamp
      Time.zone.parse(@doc['public_timestamp'])
    end

    def part_of_series?
      document_series && document_series.any?
    end

    def organisations
      @doc.fetch('organisations', []).map { |slug| @all_orgs[slug] }.compact
    end

    def topics
      @doc.fetch('topics', []).map { |slug| @all_topics[slug] }.compact
    end

    def document_series
      @doc.fetch('document_series', []).map { |slug| @all_doc_series[slug] }.compact
    end

    def operational_field
      @all_operation_fields[@doc['operational_field']]
    end
  end
end