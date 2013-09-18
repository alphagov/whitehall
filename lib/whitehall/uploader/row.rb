module Whitehall::Uploader
  class Row
    ATTACHMENT_LIMIT = 100
    attr_reader :row, :line_number

    def initialize(row, line_number, attachment_cache, default_organisation, logger = Logger.new($stdout))
      @row = row
      @line_number = line_number
      @logger = logger
      @attachment_cache = attachment_cache
      @default_organisation = default_organisation
    end

    def self.heading_validation_errors(headings)
      validator.errors(headings)
    end

    def self.validator
      HeadingValidator.new
        .required(%w{old_url title summary body organisation})
        .multiple("body_#", 0..9)
    end

    def title
      row['title']
    end

    def summary
      summary_text = Parsers::RelativeToAbsoluteLinks.parse(row['summary'], organisation.try(:url))
      if summary_text.blank?
        Parsers::SummariseBody.parse(body)
      else
        summary_text
      end
    end

    def body
      body_parts = [row['body']] + (1..9).map {|n| row["body_#{n}"]}
      Parsers::RelativeToAbsoluteLinks.parse(body_parts.compact.join(''), organisation.try(:url))
    end

    def translated_title
      row['title_translation'].to_s
    end

    def translated_summary
      summary_text = Parsers::RelativeToAbsoluteLinks.parse(row['summary_translation'], organisation.try(:url))
      if summary_text.blank?
        Parsers::SummariseBody.parse(translated_body).to_s
      else
        summary_text.to_s
      end
    end

    def translated_body
      Parsers::RelativeToAbsoluteLinks.parse(row['body_translation'], organisation.try(:url)).to_s
    end

    def legacy_urls
      Parsers::OldUrlParser.parse(row['old_url'], @logger, @line_number)
    end

    def organisation
      @organisation ||= Finders::OrganisationFinder.find(row['organisation'], @logger, @line_number, @default_organisation).first
    end

    def organisations
      [organisation]
    end

    def lead_organisations
      organisations
    end

    def translation_present?
      translation_locale.present? || translation_attributes.values.any?(&:present?)
    end

    def translation_locale
      row['locale']
    end

    def translation_url
      row['translation_url']
    end

    # Default translation attributes. Override as required
    def translation_attributes
      {
        title: translated_title,
        body: translated_body,
        summary: translated_summary
      }
    end

    def document_series
      []
    end

    protected

    def fields(range, pattern)
      range.map do |n|
        row[pattern.gsub('#', n.to_s)]
      end
    end

    def attachments_from_json
      if row["json_attachments"]
        attachment_data = ActiveSupport::JSON.decode(row["json_attachments"])
        attachment_data.map do |attachment|
          Builders::AttachmentBuilder.build({title: attachment["title"]}, attachment["link"], @attachment_cache, @logger, @line_number)
        end
      else
        []
      end
    end

    def attachments_from_columns
      1.upto(Row::ATTACHMENT_LIMIT).map do |number|
        next unless row["attachment_#{number}_title"] || row["attachment_#{number}_url"]
        Builders::AttachmentBuilder.build({title: row["attachment_#{number}_title"]}, row["attachment_#{number}_url"], @attachment_cache, @logger, @line_number)
      end.compact
    end
  end
end
