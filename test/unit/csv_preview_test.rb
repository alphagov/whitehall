# encoding: UTF-8
require "test_helper"

class CsvPreviewTest < ActiveSupport::TestCase

  def csv_preview
    @csv_preview ||= CsvPreview.new(Rails.root.join('test/fixtures/csv_encodings/utf-8.csv'))
  end

  test "returns the header row for a CSV file" do
    assert_equal ['Department', 'Budget', 'Amount spent'], csv_preview.headings
  end

  test "yields the data, row by row" do
    expected_data = [ ['Office for Facial Hair Studies', '£12000000' , '£10000000'],
                      ['Department of Grooming','£15000000','£15600000'] ]

    assert_csv_data expected_data, csv_preview
  end

  test "handles iso-8859-1 encoded files" do
    iso_encoded_preview = CsvPreview.new(Rails.root.join('test/fixtures/csv_encodings/iso-8859-1.csv'))

    assert_equal ['ECO Lot', 'Band', 'Contract Term', 'Price Per Unit', 'Above reserve price?', 'Reserve Price (£)'],
      iso_encoded_preview.headings

    expected_data = [ ['Carbon Saving Communities','Carbon Saving Band 1 [1K-3K]','3 months','£69.10','YES',nil],
                      ['Carbon Saving Communities','Carbon Saving Band 1 [1K-3K]','12 months','£62.10','YES','£40.00'] ]

    assert_csv_data(expected_data, iso_encoded_preview)
  end

  test "handles windows-1252 encoded files" do
    iso_encoded_preview = CsvPreview.new(File.open(Rails.root.join('test/fixtures/csv_encodings/windows-1252.csv')))

    assert_equal %w(name address1 address2 town postcode access_notes general_notes url email phone fax text_phone),
      iso_encoded_preview.headings
  end

  test "raises CsvPreview::FileEncodingError if the encoding cannot be handled by the CSV library" do
    CSV.expects(:open).raises(ArgumentError, 'invalid byte sequence in UTF-8')

    assert_raise CsvPreview::FileEncodingError do
      CsvPreview.new(Rails.root.join('test/fixtures/csv_encodings/utf-8.csv'))
    end
  end

  test 'the size of the preview is limited to 1,000 rows of data by default' do
    assert_equal 1_000, csv_preview.maximum_rows
  end

  test 'the size of the preview can be overridden' do
    preview       = CsvPreview.new(File.open(Rails.root.join('test/fixtures/csv_encodings/utf-8.csv')), 1)
    expected_data = [ ['Office for Facial Hair Studies', '£12000000' , '£10000000'] ]

    assert_csv_data(expected_data, preview)
  end

  test '#truncated? returns true if the preview does not show the entire file contents' do
    csv_preview.each_row {}
    refute csv_preview.truncated?

    truncated_preview = CsvPreview.new(Rails.root.join('test/fixtures/csv_encodings/utf-8.csv'), 1)
    truncated_preview.each_row {}
    assert truncated_preview.truncated?
  end

private

  def assert_csv_data(expected_data, preview)
    index = 0

    preview.each_row do |row|
      assert_equal expected_data[index], row
      index += 1
    end
  end
end
