namespace :attachments do
  desc "Repair attachments that have double extensions, e.g. filename.pdf.pdf"
  task repair: :environment do
    logger=Logger.new($stderr)
    gds_user = User.find_by_name!("GDS Inside Government Team")

    logger.info "Cleaning up Document with misnamed attachment files"
    logger.info "Note: Only published or draft documents will be fixed"

    document_ids = []
    AttachmentUploader::EXTENSION_WHITE_LIST.each do |ext|
      query = "SELECT DISTINCT document_id FROM editions
        INNER JOIN edition_attachments on edition_attachments.edition_id = editions.id
        INNER JOIN attachments ON edition_attachments.attachment_id = attachments.id
        INNER JOIN attachment_Data ON attachments.attachment_data_id = attachment_data.id
        WHERE editions.state IN ('published', 'draft') AND
              replaced_by_id IS NULL
              AND carrierwave_file LIKE \"%.#{ext}.#{ext}\""

      document_ids += ActiveRecord::Base.connection.execute(query).to_a.flatten
    end
    document_ids.uniq!

    logger.info "\n#{document_ids.size} Document(s) found with misnamed attachments."

    Document.where(id: document_ids).includes(:latest_edition, :published_edition).find_each do |document|
      DataHygiene::DocumentAttachmentRepairer.new(document, gds_user, logger).repair_attachments!
    end
  end
end
