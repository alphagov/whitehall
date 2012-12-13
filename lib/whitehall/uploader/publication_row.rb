require 'whitehall/uploader/finders'
require 'whitehall/uploader/parsers'
require 'whitehall/uploader/builders'
require 'whitehall/uploader/row'

module Whitehall::Uploader
  class PublicationRow < Row
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
        .multiple("policy_#", 1..4)
        .required(%w{publication_type document_series publication_date})
        .optional(%w{order_url price isbn urn command_paper_number}) # First attachment
        .ignored("ignore_*")
        .multiple(%w{attachment_#_url attachment_#_title}, 0..Row::ATTACHMENT_LIMIT)
        .optional('json_attachments')
        .multiple("country_#", 0..4)
    end

    def title
      row['title']
    end

    def summary
      row['summary']
    end

    def body
      row['body']
    end

    def legacy_url
      row['old_url']
    end

    def publication_date
      Parsers::DateParser.parse(row['publication_date'], @logger, @line_number)
    end

    def publication_type
      Finders::PublicationTypeFinder.find(row['publication_type'], @logger, @line_number)
    end

    def related_policies
      Finders::PoliciesFinder.find(row['policy_1'], row['policy_2'], row['policy_3'], row["policy_4"], @logger, @line_number)
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
      Finders::DocumentSeriesFinder.find(row['document_series'], @logger, @line_number)
    end

    def ministerial_roles
      Finders::MinisterialRolesFinder.find(publication_date, row['minister_1'], row['minister_2'], @logger, @line_number)
    end

    def attachments
      if @attachments.nil?
        @attachments = attachments_from_columns + attachments_from_json
        AttachmentMetadataBuilder.build(@attachments.first, row["order_url"], row["isbn"], row["urn"], row["command_paper_number"], row["price"])
      end
      @attachments
    end

    def alternative_format_provider
      organisations.first
    end

    def world_locations
      Finders::WorldLocationsFinder.find(row['country_1'], row['country_2'], row['country_3'], row['country_4'], @logger, @line_number)
    end

    def attributes
      [:title, :summary, :body, :publication_date, :publication_type,
       :related_policies, :lead_edition_organisations, :document_series,
       :ministerial_roles, :attachments, :alternative_format_provider,
       :world_locations].map.with_object({}) do |name, result|
        result[name] = __send__(name)
      end
    end

    private

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

    class AttachmentMetadataBuilder
      def self.build(attachment, order_url, isbn, unique_reference, command_paper_number, price)
        return unless attachment && (order_url || isbn || unique_reference || command_paper_number || price)
        attachment.order_url = order_url
        attachment.isbn = isbn
        attachment.unique_reference = unique_reference
        attachment.command_paper_number = command_paper_number
        attachment.price = price
      end
    end
  end
end
