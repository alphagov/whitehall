require 'whitehall/uploader/finders'
require 'whitehall/uploader/parsers'
require 'whitehall/uploader/builders'
require 'whitehall/uploader/row'

module Whitehall::Uploader
  class StatisticalDataSetRow < Row
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
        .required(%w{old_url title summary body organisation})
        .required(%w{data_series})
        .multiple(%w{attachment_#_url attachment_#_title attachment_#_URN attachment_#_published_date}, 0..100)
        .ignored("ignore_*")
    end

    def title
      row['title']
    end

    def summary
      row['summary']
    end

    def body
      body = row['body']
      body.blank? ? generated_attachment_body : body
    end

    def legacy_url
      row["old_url"]
    end

    def organisations
      Finders::OrganisationFinder.find(row['organisation'], @logger, @line_number, @default_organisation)
    end

    def lead_edition_organisations
      organisations.map.with_index do |o, idx|
        Builders::EditionOrganisationBuilder.build_lead(o, idx + 1)
      end
    end

    def document_series
      Finders::DocumentSeriesFinder.find(row['data_series'], @logger, @line_number)
    end

    def attachments
      @attachments ||= attachments_from_columns
    end

    def alternative_format_provider
      organisations.first
    end

    def attributes
      [:title, :summary, :body, :lead_edition_organisations, :document_series,
       :attachments, :alternative_format_provider].map.with_object({}) do |name, result|
        result[name] = __send__(name)
      end
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
