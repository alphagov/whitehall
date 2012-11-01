require 'csv'

logger = Logger.new($stdout)
affected_files = Dir[File.expand_path(File.dirname(__FILE__)) + "/*upload_{dft,dclg,brac,pins}_publications.csv"]
affected_files.each do |affected_file|
  logger.info "Processing file #{affected_file}"
  csv = CSV.read(affected_file, headers: true)
  csv.each_with_index do |data_row, ix|
    row = Whitehall::Uploader::PublicationRow.new(data_row.to_hash, ix + 1, logger)
    begin
      attachment_urls = (1..50).map { |x| data_row["attachment_#{x}_url"] }.compact
      found, missing = attachment_urls.partition { |url|
        AttachmentSource.find_by_url(url)
      }
      if missing.any?
        if found.any?
          edition = AttachmentSource.find_by_url(url).attachment.editions.last
          logger.warn "Row #{ix + 2} '#{row.legacy_url}' missing attachments (Edition #{edition.id}) - #{missing.inspect}"
        else
          logger.warn "Row #{ix + 2} '#{row.legacy_url}' missing attachments - #{missing.inspect}"
        end
      end
    end
  end
  logger.info "Finished processing file #{affected_file}"
end
