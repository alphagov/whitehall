require 'csv'

module DataHygiene
  class DuplicateAttachmentFinder
    DUP_EDITION_ATTACHMENT_SQL = <<-HEREDOC
      SELECT attachable_id as id, attachment_data.carrierwave_file as filename FROM attachments
      JOIN attachment_data on attachments.attachment_data_id = attachment_data.id
      JOIN editions on attachable_id = editions.id
      WHERE attachable_type = "Edition" AND editions.state = 'published'
      GROUP BY attachable_type, attachable_id, attachment_data.carrierwave_file
      HAVING count(*) > 1;
    HEREDOC

    DUP_NON_EDITION_ATTACHMENT_SQL = <<-HEREDOC
      SELECT attachable_type, attachable_id as id FROM attachments
      JOIN attachment_data on attachments.attachment_data_id = attachment_data.id
      WHERE attachable_type != "Edition" and attachable_type != "SupportingPage"
      GROUP BY attachable_type, attachable_id, attachment_data.carrierwave_file
      HAVING count(*) > 1;
    HEREDOC

    def editions
      Edition.where(id: edition_ids)
    end

    def non_editions
      duplicate_non_edition_results.collect do |results|
        type, id = results
        type.constantize.find(id)
      end
    end

    def csv_dump
      CSV.generate do |csv|
        csv << %w(TYPE ID DEPARTMENT ADMIN_URL PUBLIC_URL FILENAME IDENTICAL?)
        duplicate_edition_results.each do |duplicate_info|
          id, filename, _       = duplicate_info
          edition               = Edition.find(id)
          duplicate_attachments = edition.attachments.includes(:attachment_data).where(attachment_data: {carrierwave_file: filename})
          attachment_ids        = duplicate_attachments.map(&:id)
          file_sizes            = duplicate_attachments.map(&:file_size)
          all_the_same          = file_sizes.uniq.size == 1

          csv << [edition.type,
                  edition.id,
                  edition_organisation_name(edition),
                  Whitehall.url_maker.url_for([:admin, edition]),
                  Whitehall.url_maker.public_document_url(edition),
                  filename,
                  all_the_same]
        end
      end
    end

    def duplicate_edition_results
      @duplicate_edition_results ||= ActiveRecord::Base.connection.execute(DUP_EDITION_ATTACHMENT_SQL).to_a
    end

    def edition_ids
      duplicate_edition_results.collect(&:first)
    end

    def duplicate_non_edition_results
      ActiveRecord::Base.connection.execute(DUP_NON_EDITION_ATTACHMENT_SQL).to_a
    end

  private

    def edition_organisation_name(edition)
      if edition.is_a?(WorldLocationNewsArticle)
        edition.worldwide_organisations.first.name
      else
        edition.lead_organisations.first.name
      end
    end
  end
end
