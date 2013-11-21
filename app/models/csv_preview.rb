require 'csv'

class CsvPreview
  class FileEncodingError < ::EncodingError
  end

  attr_reader :file_path, :headings, :maximum_rows

  def initialize(file_path, maximum_rows=1_000)
    @maximum_rows = maximum_rows
    @file_path = file_path
    @csv = CSV.open(@file_path, encoding: guess_encoding)
    @headings = @csv.shift
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

  def guess_encoding
    file = File.open(file_path)
    sample = (1...5).collect { file.readline unless file.eof? }.join

    if utf_8_encoding?(sample)
      'UTF-8'
    elsif windows_1252_encoding?(sample)
      'windows-1252'
    else
      raise FileEncodingError, 'File encoding not recognised'
    end
  end

  def utf_8_encoding?(text)
    text.force_encoding('utf-8').valid_encoding?
  end

  def windows_1252_encoding?(text)
    text.force_encoding('windows-1252')
    # This regexp checks for the presence of ASCII control characters, which
    # would indicate we have the wrong encoding.
    text.valid_encoding? && !text.match(/[\x00-\x09\x0b\x0c\x0e-\x1f]/)
  end
end
