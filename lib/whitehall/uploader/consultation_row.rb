require 'whitehall/uploader/finders'
require 'whitehall/uploader/parsers'
require 'whitehall/uploader/builders'
require 'whitehall/uploader/row'

module Whitehall::Uploader
  class ConsultationRow < Row
    attr_reader :row

    def initialize(row, line_number, attachment_cache, logger = Logger.new($stdout))
      @row = row
      @line_number = line_number
      @logger = logger
      @attachment_cache = attachment_cache
    end

    def self.required_fields(headings)
      required_fields = super.dup
      required_fields += %w{policy_1 policy_2 policy_3 policy_4}
      required_fields += %w{
        minister_1 minister_2
        opening_date closing_date
        respond_url respond_email
        respond_postal_address respond_form_title respond_form_attachment
        consultation_ISBN consultation_URN publication_date order_url
        command_paper_number price response_date response_summary comments
      }
      required_fields += provided_response_ids(headings).map do |i|
        "response_#{i}_url response_#{i}_title response_#{i}_ISBN response_#{i}_URN response_#{i}_command_reference response_#{i}_order_URL response_#{i}_price".split(" ")
      end.flatten
      required_fields += provided_attachment_ids(headings).map do |i|
        "attachment_#{i}_url attachment_#{i}_title".split(" ")
      end.flatten
      required_fields
    end

    def title
      row['title']
    end

    def summary
      Parsers::RelativeToAbsoluteLinks.parse(row['summary'], organisation.url)
    end

    def legacy_url
      row['old_url']
    end

    def opening_on
      Parsers::DateParser.parse(row['opening_date'], @logger, @line_number)
    end

    def closing_on
      Parsers::DateParser.parse(row['closing_date'], @logger, @line_number)
    end

    def body
      Parsers::RelativeToAbsoluteLinks.parse(row['body'], organisation.url)
    end

    def organisation
      @organisation ||= Finders::OrganisationFinder.find(row['organisation'], @logger, @line_number).first
    end

    def organisations
      [organisation]
    end

    def related_policies
      Finders::PoliciesFinder.find(row['policy_1'], row['policy_2'], row['policy_3'], row['policy_4'], @logger, @line_number)
    end

    def alternative_format_provider
      organisation
    end

    def attachments
      @attachments ||= build_attachments
    end

    def response
      ResponseBuilder.new(@row, @line_number, @attachment_cache, @logger).build
    end

    def attributes
      {
        title: title,
        summary: summary,
        body: body,
        opening_on: opening_on,
        closing_on: closing_on,
        organisations: organisations,
        related_policies: related_policies,
        attachments: attachments,
        alternative_format_provider: alternative_format_provider,
        response: response
      }
    end

    private

    def build_attachments
      result = 1.upto(50).map do |number|
        if row["attachment_#{number}_title"] || row["attachment_#{number}_url"]
          Builders::AttachmentBuilder.build({title: row["attachment_#{number}_title"]}, row["attachment_#{number}_url"], @attachment_cache, @logger, @line_number)
        end
      end.compact

      if consultation = result.first
        consultation.unique_reference = row["consultation_urn"]
        consultation.isbn = row["consultation_isbn"]
      end

      result
    end

    class ResponseBuilder
      attr_reader :row

      def initialize(row, line_number, attachment_cache, logger = Logger.new($stdout), response_class = Response)
        @row = row
        @attachment_cache = attachment_cache
        @line_number = line_number
        @logger = logger
        @response_class = response_class
      end

      def summary
        @row['response_summary']
      end

      def published_on
        Parsers::DateParser.parse(row['response_date'], @logger, @line_number)
      end

      def attachments
        @attachments ||= build_attachments
      end

      def build
        if published_on || summary || attachments.any?
          @response_class.new(
            published_on: published_on,
            summary: summary,
            attachments: attachments
          )
        end
      end

      private

      def build_attachments
        1.upto(50).map do |number|
          if row["response_#{number}_title"] || row["response_#{number}_url"]
            attachment = Builders::AttachmentBuilder.build({title: row["response_#{number}_title"]}, row["response_#{number}_url"], @attachment_cache, @logger, @line_number)
            attachment.isbn = row["response_#{number}_isbn"]
            attachment
          end
        end.compact
      end
    end
  end
end
