require 'csv'

class Whitehall::Uploader::Csv
  attr_reader :row_class, :model_class

  def initialize(data, row_class, model_class, attachment_cache, logger = Logger.new($stdout), error_csv_path=nil)
    @csv = CSV.new(data, headers: true)
    @row_class = row_class
    @model_class = model_class
    @logger = logger
    @attachment_cache = attachment_cache
    @error_csv_path = error_csv_path || "#{Time.zone.now.to_s(:number)}_import_errors.csv"
  end

  def import_as(creator)
    @csv.each_with_index do |data_row, ix|
      row = row_class.new(data_row.to_hash, ix + 1, @attachment_cache, @logger)
      begin
        if DocumentSource.find_by_url(row.legacy_url)
          @logger.warn "Row #{ix + 2} '#{row.legacy_url}' has already been imported"
        else
          attributes = row.attributes.merge(creator: creator)
          model = model_class.new(attributes)
          if model.save
            DocumentSource.create!(document: model.document, url: row.legacy_url)
          else
            store_error(data_row, model.errors.full_messages)
            @logger.warn "Row #{ix + 2} '#{row.legacy_url}' couldn't be saved for the following reasons: #{model.errors.full_messages}"
          end
        end
      rescue => e
        store_error(data_row, e.to_s)
      end
    end
  ensure
    write_error_file
  end

  private

  ERROR_MESSAGE_HEADER = "import_error_messages"

  def store_error(row, error_messages)
    @error_csv_headers ||= [ERROR_MESSAGE_HEADER] + @csv.headers
    @error_csv ||= CSV.open(@error_csv_path, "wb", write_headers: true, headers: @error_csv_headers)
    row[ERROR_MESSAGE_HEADER] = error_messages
    @error_csv << row.fields(*@error_csv_headers)
  end

  def write_error_file
    if @error_csv
      @error_csv.close
      @logger.warn "Errors written to #{@error_csv_path}"
    end
  end
end
