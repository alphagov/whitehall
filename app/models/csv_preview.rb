require 'csv'
require 'charlock_holmes'

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
    sample = File.readlines(file_path, 5).join
    detection = CharlockHolmes::EncodingDetector.detect(sample)
    detection[:encoding]
  end
end
