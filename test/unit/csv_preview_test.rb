# encoding: UTF-8

require "test_helper"

class CsvPreviewTest < ActiveSupport::TestCase
  def csv_preview
    @csv_preview ||= CsvPreview.new(Rails.root.join("test", "fixtures", "csv_encodings", "utf-8.csv"))
  end

  test "returns the header row for a CSV file" do
    assert_equal ['Department', 'Budget', 'Amount spent'], csv_preview.headings
  end

  test "yields the data, row by row" do
    expected_data = [['Office for Facial Hair Studies', '£12000000', '£10000000'],
                     ['Department of Grooming', '£15000000', '£15600000']]

    assert_csv_data expected_data, csv_preview
  end

  test "handles iso-8859-1 encoded files" do
    iso_encoded_preview = CsvPreview.new(Rails.root.join("test", "fixtures", "csv_encodings", "iso-8859-1.csv"))

    assert_equal ['ECO Lot', 'Band', 'Contract Term', 'Price Per Unit', 'Above reserve price?', 'Reserve Price (£)'],
                 iso_encoded_preview.headings

    expected_data = [['Carbon Saving Communities', 'Carbon Saving Band 1 [1K-3K]', '3 months', '£69.10', 'YES', nil],
                     ['Carbon Saving Communities', 'Carbon Saving Band 1 [1K-3K]', '12 months', '£62.10', 'YES', '£40.00']]

    assert_csv_data(expected_data, iso_encoded_preview)
  end

  test "handles windows-1252 encoded files" do
    iso_encoded_preview = CsvPreview.new(File.open(Rails.root.join("test","fixtures","csv_encodings","windows-1252.csv")))

    assert_equal %w(name address1 address2 town postcode access_notes general_notes url email phone fax text_phone),
                 iso_encoded_preview.headings
  end

  test "raises CsvPreview::FileEncodingError if the encoding cannot be handled by the CSV library" do
    CSV.expects(:open).raises(ArgumentError, 'invalid byte sequence in UTF-8')
    assert_raise CsvPreview::FileEncodingError do
      CsvPreview.new(Rails.root.join("test", "fixtures", "csv_encodings", "utf-8.csv"))
    end
  end

  test "handles UTF-8 conversion errors caused by unrecognised characters" do
    assert_raise CsvPreview::FileEncodingError do
      CsvPreview.new(Rails.root.join("test", "fixtures", "csv_encodings", "strange-encoding.csv"))
    end
  end

  test 'the size of the preview is limited to 1,000 rows of data by default' do
    assert_equal 1_000, csv_preview.maximum_rows
  end

  test 'the size of the preview is limited to 50 columns of data by default' do
    assert_equal 50, csv_preview.maximum_columns
  end

  test 'the size of the preview can be overridden' do
    preview       = CsvPreview.new(File.open(Rails.root.join("test", "fixtures", "csv_encodings", "utf-8.csv")), 1)
    expected_data = [['Office for Facial Hair Studies', '£12000000', '£10000000']]

    assert_csv_data(expected_data, preview)
  end

  test '#truncated? returns true if the preview does not include all the rows' do
    csv_preview.each_row {}
    assert_not csv_preview.truncated?

    truncated_preview = CsvPreview.new(Rails.root.join("test", "fixtures", "csv_encodings", "utf-8.csv"), 1)
    truncated_preview.each_row {}
    assert truncated_preview.truncated?
  end

  test '#truncated? returns true if the preview does not include all the columns' do
    csv_preview.each_row {}
    assert_not csv_preview.truncated?

    truncated_preview = CsvPreview.new(Rails.root.join("test", "fixtures", "csv_encodings", "utf-8.csv"), 10, 1)
    truncated_preview.each_row {}

    assert truncated_preview.truncated?
  end

  test 'raises CSV::MalformedCSVError early if the data cannot be handled by the CSV library' do
    assert_raise CSV::MalformedCSVError do
      CsvPreview.new(Rails.root.join("test", "fixtures", "csv_encodings", "eof.csv"))
    end
  end

  test 'handles files with a newline embedded in a cell in the first row that is not the same as the newlines used to separate the rows' do
    mixed_newlines_preview = CsvPreview.new(Rails.root.join("test", "fixtures", "csv_encodings", "mixed-newlines.csv"))

    assert_equal ['this', 'header row', "has an embedded new\nline but", 'it is different to', 'the row separator'],
                 mixed_newlines_preview.headings

    expected_data = [['this', 'is', 'the', 'second', 'line in the file']]

    assert_csv_data(expected_data, mixed_newlines_preview)
  end

private

  def assert_csv_data(expected_data, preview)
    index = 0

    preview.each_row do |row|
      assert_equal expected_data[index], row
      index += 1
    end

    assert_equal expected_data.size, index
  end
end
