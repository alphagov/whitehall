require "test_helper"

class StatisticalDataSetTest < EditionTestCase
  test "should include the Edition::DocumentSeries behaviour" do
    assert StatisticalDataSet.ancestors.include?(Edition::DocumentSeries)
  end
end