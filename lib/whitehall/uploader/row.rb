module Whitehall::Uploader
  class Row
    ATTACHMENT_LIMIT = 100
    attr_reader :row

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
        .optional("body_#", 1..5)
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
      body_parts = [row['body']] + (1..5).map {|n| row["body_#{n}"]}
      Parsers::RelativeToAbsoluteLinks.parse(body_parts.compact.join(''), organisation.try(:url))
    end

    def translated_title
      row['title_translation']
    end

    def translated_summary
      summary_text = Parsers::RelativeToAbsoluteLinks.parse(row['summary_translation'], organisation.try(:url))
      if summary_text.blank?
        Parsers::SummariseBody.parse(translated_body)
      else
        summary_text
      end
    end

    def translated_body
      Parsers::RelativeToAbsoluteLinks.parse(row['body_translation'], organisation.try(:url))
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
      translation_locale.present?
    end

    def translation_locale
      row['locale']
    end

    def translation_url
      row['translation_url']
    end

    protected

    def fields(range, pattern)
      range.map do |n|
        row[pattern.gsub('#', n.to_s)]
      end
    end

    def self.provided_response_ids(headings)
      headings.map do |k|
        if match = k.match(/^response_([0-9]+).*$/)
          match[1]
        end
      end.compact.uniq
    end

    def self.provided_attachment_ids(headings)
      headings.map do |k|
        if match = k.match(/^attachment_([0-9]+).*$/)
          match[1]
        end
      end.compact.uniq
    end
  end
end
