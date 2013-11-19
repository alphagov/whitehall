module Whitehall::Uploader
  class StatisticalDataSetRow < Row
    DEFAULT_CHANGE_NOTE = 'Data set updated.'
    attr_reader :row

    def initialize(row, line_number, attachment_cache, default_organisation, logger = Logger.new($stdout))
      @row = row
      @line_number = line_number
      @logger = logger
      @attachment_cache = attachment_cache
      @default_organisation = default_organisation
    end

    def self.validator
      HeadingValidator.new
        .required(%w{old_url title summary body organisation first_published})
        .required(%w{document_collection_1 document_collection_2 document_collection_3 document_collection_4})
        .optional(%W{change_note})
        .multiple(%w{attachment_#_url attachment_#_title attachment_#_URN attachment_#_published_date}, 0..100)
        .ignored("ignore_*")
        .multiple("topic_#", 0..4)
    end

    def title
      row['title']
    end

    def summary
      summary_text = row['summary']
      if summary_text.blank?
        Parsers::SummariseBody.parse(body)
      else
        summary_text
      end
    end

    def body
      body = row['body']
      body.blank? ? generated_attachment_body : body
    end

    def legacy_urls
      [row["old_url"]]
    end

    def organisations
      Finders::OrganisationFinder.find(row['organisation'], @logger, @line_number, @default_organisation)
    end

    def lead_organisations
      organisations
    end

    def document_collections
      fields(1..4, 'document_collection_#').compact.reject(&:blank?)
    end

    def first_published_at
      Parsers::DateParser.parse(row['first_published'], @logger, @line_number)
    end

    def change_note
      if row['change_note'].blank?
        StatisticalDataSetRow::DEFAULT_CHANGE_NOTE
      else
        row['change_note']
      end
    end

    def attachments
      @attachments ||= attachments_from_columns
    end

    def alternative_format_provider
      organisations.first
    end

    def access_limited
      false
    end

  protected
    def attribute_keys
      super + [
        :access_limited,
        :alternative_format_provider,
        :attachments,
        :change_note,
        :first_published_at,
        :lead_organisations,
        :topics
      ]
    end

  private
    def generated_attachment_body
      attachments.map.with_index { |_, i| "!@#{i+1}" }.join("\n\n")
    end

    def attachments_from_columns
      1.upto(100).map do |number|
        next unless row["attachment_#{number}_title"] || row["attachment_#{number}_url"]
        attributes = {
          title: row["attachment_#{number}_title"],
          unique_reference: row["attachment_#{number}_urn"],
          created_at: row["attachment_#{number}_published_date"]
        }
        Builders::AttachmentBuilder.build(attributes, row["attachment_#{number}_url"], @attachment_cache, @logger, @line_number)
      end.compact
    end
  end
end
