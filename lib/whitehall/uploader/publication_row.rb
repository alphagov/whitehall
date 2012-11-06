module Whitehall::Uploader
  class PublicationRow
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
      Finders::OrganisationFinder.find(row['organisation'], @logger, @line_number)
    end

    def document_series
      Finders::DocumentSeriesFinder.find(row['document_series'], @logger, @line_number)
    end

    def ministerial_roles
      Finders::MinisterialRolesFinder.find(publication_date, row['minister_1'], row['minister_2'], @logger, @line_number)
    end

    def attachments
      if @attachments.nil?
        @attachments = 1.upto(50).map do |number|
          next unless row["attachment_#{number}_title"] || row["attachment_#{number}_url"]
          Builders::AttachmentBuilder.build(row["attachment_#{number}_title"], row["attachment_#{number}_url"], @attachment_cache, @logger, @line_number)
        end.compact
        AttachmentMetadataBuilder.build(@attachments.first, row["order_url"], row["isbn"], row["urn"], row["command_paper_number"])
      end
      @attachments
    end

    def alternative_format_provider
      organisations.first
    end

    def attributes
      [:title, :summary, :body, :publication_date, :publication_type,
       :related_policies, :organisations, :document_series,
       :ministerial_roles, :attachments, :alternative_format_provider].map.with_object({}) do |name, result|
        result[name] = __send__(name)
      end
    end

    class AttachmentMetadataBuilder
      def self.build(attachment, order_url, isbn, unique_reference, command_paper_number)
        return unless attachment && (order_url || isbn || unique_reference || command_paper_number)
        attachment.order_url = order_url
        attachment.isbn = isbn
        attachment.unique_reference = unique_reference
        attachment.command_paper_number = command_paper_number
      end
    end
  end
end
