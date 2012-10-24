require "test_helper"

class StatisticalDataSetTest < EditionTestCase
  should_allow_inline_attachments
  should_allow_a_summary_to_be_written

  test "should include the Edition::DocumentSeries behaviour" do
    assert StatisticalDataSet.ancestors.include?(Edition::DocumentSeries)
  end
end