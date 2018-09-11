require 'csv'

class CsvPreview
  class FileEncodingError < ::EncodingError
  end

  attr_reader :file_path, :headings, :maximum_rows, :maximum_columns

  def initialize(file_path, maximum_rows = 1_000, maximum_columns = 50)
    @maximum_rows = maximum_rows
    @maximum_columns = maximum_columns
    @file_path = file_path
    @csv = open_csv
    @headings = @csv.shift
    if @headings.size > maximum_columns
      @truncated_columns = true
      @headings = @headings[0..maximum_columns]
    end
    ensure_csv_data_is_well_formed
  rescue ArgumentError => e
    if e.message.match?(/invalid byte sequence/)
      raise_encoding_error
    else
      raise
    end
  rescue Encoding::UndefinedConversionError
    raise_encoding_error
  end

  def each_row
    (0...maximum_rows).each do
      if (row = @csv.shift)
        if row.size > maximum_columns
          @truncated_columns = true
          yield row[0..maximum_columns]
        else
          yield row
        end
      else
        return
      end
    end
    @truncated_rows = true
  ensure
    reset
  end

  def truncated?
    @truncated_rows || @truncated_columns
  end

  def reset
    @csv.rewind
    @csv.shift
  end

private

  def open_csv
    original_error = nil
    row_sep = :auto
    csv = nil
    begin
      csv = CSV.open(file_path, encoding: encoding, row_sep: row_sep)
      csv.shift
      csv.rewind
    rescue CSV::MalformedCSVError => e
      if original_error.nil?
        original_error = e
        row_sep = "\r\n"
        retry
      else
        raise original_error
      end
    end
    csv
  end

  def preview_rows
    @preview_rows ||= File.foreach(file_path).take(maximum_rows + 1).join
  end

  def encoding
    @encoding ||= if utf_8_encoding?
                    'UTF-8'
                  elsif windows_1252_encoding?
                    'windows-1252'
                  else
                    raise FileEncodingError, 'File encoding not recognised'
                  end
  end

  def utf_8_encoding?
    preview_rows.force_encoding('utf-8').valid_encoding?
  end

  def windows_1252_encoding?
    preview_rows.force_encoding('windows-1252')
    # This regexp checks for the presence of ASCII control characters, which
    # would indicate we have the wrong encoding.
    preview_rows.valid_encoding? && !preview_rows.match(/[\x00-\x08\x0b\x0c\x0e-\x1f]/)
  end

  def ensure_csv_data_is_well_formed
    # We iterate over the CSV data to ensure all the data is sound and won't
    # cause errors later when it's iterated over.
    each_row {}
  end

  def raise_encoding_error
    raise FileEncodingError, 'File encoding not recognised'
  end
end
