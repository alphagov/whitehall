require 'csv'
require 'charlock_holmes'

class CsvPreview
  MAXIMUM_ROWS = 1_000

  class FileEncodingError < ::EncodingError
  end

  attr_reader :file_path, :headings

  def initialize(file_path)
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
    (0...MAXIMUM_ROWS).each do
      break unless row = @csv.shift
      yield row
    end
  ensure
    reset
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
