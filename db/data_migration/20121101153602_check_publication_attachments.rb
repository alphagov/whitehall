require 'csv'

logger = Logger.new($stdout)
affected_files = [
  '20121029125200_upload_dft_publications.csv',
  '20121029160239_upload_dclg_publications.csv',
  '20121030160045_upload_brac_publications.csv',
  '20121030160102_upload_pins_publications.csv'
].map { |filename| Rails.root.join('db/data_migration/', filename) }

affected_files.each do |affected_file|
  logger.info "Processing file #{affected_file}"
  csv = CSV.read(affected_file, headers: true)
  csv.each_with_index do |data_row, ix|
    row = Whitehall::Uploader::PublicationRow.new(data_row.to_hash, ix + 1, logger)
    begin
      attachment_urls = (1..50).map { |x| data_row["attachment_#{x}_url"] }.compact
      document_source = DocumentSource.find_by_url(row.legacy_url)
      found, missing = attachment_urls.partition { |url|
        AttachmentSource.find_by_url(url)
      }
      if missing.any?
        edition = if found.any?
          AttachmentSource.find_by_url(found.first).attachment.editions.last
        elsif document_source
          document_source.document.latest_edition
        end
        if edition
          logger.warn "Row #{ix + 2} '#{row.legacy_url}' missing attachments (Edition #{edition.id}) - #{missing.inspect}"
        else
          logger.warn "Row #{ix + 2} '#{row.legacy_url}' missing attachments - #{missing.inspect}"
        end
      end
    end
  end
  logger.info "Finished processing file #{affected_file}"
end
