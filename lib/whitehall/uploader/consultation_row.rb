require 'whitehall/uploader/finders'
require 'whitehall/uploader/parsers'
require 'whitehall/uploader/builders'

module Whitehall::Uploader
  class ConsultationRow
    attr_reader :row

    def initialize(row, line_number, attachment_cache, logger = Logger.new($stdout))
      @row = row
      @line_number = line_number
      @logger = logger
      @attachment_cache = attachment_cache
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
          Builders::AttachmentBuilder.build(row["attachment_#{number}_title"], row["attachment_#{number}_url"], @attachment_cache, @logger, @line_number)
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
            attachment = Builders::AttachmentBuilder.build(row["response_#{number}_title"], row["response_#{number}_url"], @attachment_cache, @logger, @line_number)
            attachment.isbn = row["response_#{number}_isbn"]
            attachment
          end
        end.compact
      end
    end
  end
end
