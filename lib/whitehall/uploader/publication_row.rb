module Whitehall::Uploader
  class PublicationRow < Row
    def self.validator
      super
        .multiple("policy_#", 0..4)
        .multiple("document_collection_#", 0..4)
        .required(%w{publication_type publication_date})
        .optional(%w{order_url price isbn urn command_paper_number}) # First attachment
        .optional(%w{hoc_paper_number parliamentary_session unnumbered_hoc_paper unnumbered_command_paper}) # First attachment
        .ignored("ignore_*")
        .multiple(%w{attachment_#_url attachment_#_title}, 0..Row::ATTACHMENT_LIMIT)
        .optional('json_attachments')
        .multiple("country_#", 0..4)
        .optional(%w(html_title html_body))
        .multiple('html_body_#',0..50)
    end

    def first_published_at
      Parsers::DateParser.parse(row['publication_date'], @logger, @line_number)
    end

    def publication_type
      Finders::PublicationTypeFinder.find(row['publication_type'], @logger, @line_number)
    end

    def related_editions
      Finders::EditionFinder.new(Policy, @logger, @line_number).find(row['policy_1'], row['policy_2'], row['policy_3'], row["policy_4"])
    end

    def document_collection
      Finders::EditionFinder.new(DocumentCollection, @logger, @line_number).find(*fields(1..4, 'document_collection_#'))
    end

    def ministerial_roles
      Finders::MinisterialRolesFinder.find(first_published_at, row['minister_1'], row['minister_2'], @logger, @line_number)
    end

    def attachments
      if @attachments.nil?
        @attachments = attachments_from_columns + attachments_from_json
        apply_meta_data_to_attachment(@attachments.first) if @attachments.any?
      end
      @attachments
    end

    def alternative_format_provider
      organisations.first
    end

    def world_locations
      Finders::WorldLocationsFinder.find(row['country_1'], row['country_2'], row['country_3'], row['country_4'], @logger, @line_number)
    end

    def html_title
      row['html_title']
    end

    def html_body
      if row['html_body']
        ([row['html_body']] + (1..50).map {|n| row["html_body_#{n}"] }).compact.join
      end
    end

    def html_version_attributes
      { title: html_title, body: html_body }
    end

    def attributes
      [:title, :summary, :body, :first_published_at, :publication_type,
       :related_editions, :lead_organisations,
       :ministerial_roles, :attachments, :alternative_format_provider,
       :world_locations, :html_version_attributes].map.with_object({}) do |name, result|
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

    def apply_meta_data_to_attachment(attachment)
      attachment.order_url = row["order_url"]
      attachment.isbn = row["isbn"]
      attachment.unique_reference = row["urn"]
      attachment.command_paper_number = row["command_paper_number"]
      attachment.price = row["price"]
      attachment.hoc_paper_number = row["hoc_paper_number"]
      attachment.parliamentary_session = row["parliamentary_session"]
      attachment.unnumbered_hoc_paper = row["unnumbered_hoc_paper"]
      attachment.unnumbered_command_paper = row["unnumbered_command_paper"]
    end
  end
end
