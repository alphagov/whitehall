require 'csv'

class CsvPreview
  MAXIMUM_ROWS = 1_000

  def initialize(file_path)
    @csv = CSV.open(file_path, encoding: "UTF-8")
    @headings = @csv.shift
  end

  def headings
    @headings
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
end
