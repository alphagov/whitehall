require 'csv'
require 'charlock_holmes'

class CsvPreview
  MAXIMUM_ROWS = 1_000

  attr_reader :file_path, :headings

  def initialize(file_path)
    @file_path = file_path
    @csv = CSV.open(@file_path, encoding: guess_encoding)
    @headings = @csv.shift
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
    return detection[:encoding]
  end
end
