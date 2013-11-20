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

    index = 0
    @csv_preview.each_row do |row|
      assert_equal expected_data[index], row
      index += 1
    end
  end
end
