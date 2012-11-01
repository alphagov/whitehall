require 'csv'

logger = Logger.new($stdout)
affected_files = Dir[File.expand_path(File.dirname(__FILE__)) + "/*upload_{dft,dclg,brac,pins}_publications.csv"]
affected_files.each do |affected_file|
  logger.info "Processing file #{affected_file}"
  csv = CSV.read(affected_file, headers: true)
  csv.each_with_index do |data_row, ix|
    row = Whitehall::Uploader::PublicationRow.new(data_row.to_hash, ix + 1, logger)
    begin
      if source = DocumentSource.find_by_url(row.legacy_url)
        document = source.document
        edition = document.latest_edition
        edition.update_attribute :publication_date, row.publication_date
        logger.info "Row #{ix + 2} '#{row.legacy_url}' updated edition #{edition.id} to #{row.publication_date}"
      else
        logger.warn "Row #{ix + 2} '#{row.legacy_url}' could not be located"
      end
    end
  end
  logger.info "Finished processing file #{affected_file}"
end
