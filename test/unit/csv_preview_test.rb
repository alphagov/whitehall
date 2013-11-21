# encoding: UTF-8
require "test_helper"

class CsvPreviewTest < ActiveSupport::TestCase
  setup do
    @csv_preview = CsvPreview.new(File.open(Rails.root.join('test/fixtures/sample.csv')))
  end

  test "returns the header row for a CSV file" do
    assert_equal ['Department', 'Budget', 'Amount spent'], @csv_preview.headings
  end

  test "yields the data, row by row" do
    expected_data = [ ['Office for Facial Hair Studies', '£12000000' , '£10000000'],
                      ['Department of Grooming','£15000000','£15600000'] ]

    assert_csv_data expected_data, @csv_preview
  end

  test "handles non-UTF-8 encoded files" do
    csv_preview = CsvPreview.new(File.open(Rails.root.join('test/fixtures/iso-encoded.csv')))

    assert_equal ['ECO Lot', 'Band', 'Contract Term', 'Price Per Unit', 'Above reserve price?', 'Reserve Price (£)'],
      csv_preview.headings

    expected_data = [ ['Carbon Saving Communities','Carbon Saving Band 1 [1K-3K]','3 months','£69.10','YES',nil],
                      ['Carbon Saving Communities','Carbon Saving Band 1 [1K-3K]','12 months','£62.10','YES','£40.00'] ]

    assert_csv_data(expected_data, csv_preview)
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
