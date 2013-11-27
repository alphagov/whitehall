require 'csv'

class CsvPreview
  class FileEncodingError < ::EncodingError
  end

  attr_reader :file_path, :headings, :maximum_rows

  def initialize(file_path, maximum_rows=1_000)
    @maximum_rows = maximum_rows
    @file_path = file_path
    @csv = CSV.open(file_path, encoding: encoding )
    @headings = @csv.shift
    ensure_csv_data_is_well_formed
  rescue ArgumentError => e
    if e.message =~ /invalid byte sequence/
      raise FileEncodingError, 'File encoding not recognised'
    else
      raise
    end
  end

  def each_row
    (0...maximum_rows).each do
      if row = @csv.shift
        yield row
      else
        return
      end
    end
    @truncated = true
  ensure
    reset
  end

  def truncated?
    @truncated
  end

  def reset
    @csv.rewind
    @csv.shift
  end

  def preview_rows
    @preview ||= File.foreach(file_path).take(maximum_rows+1).join
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
    preview_rows.valid_encoding? && !preview_rows.match(/[\x00-\x09\x0b\x0c\x0e-\x1f]/)
  end

  def ensure_csv_data_is_well_formed
    # We iterate over the CSV data to ensure all the data is sound and won't
    # cause errors later when it's iterated over.
    each_row {}
  end
end
