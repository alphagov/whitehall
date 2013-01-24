require "test_helper"

class StatisticalDataSetTest < EditionTestCase
  should_allow_inline_attachments

  test "should include the Edition::DocumentSeries behaviour" do
    assert StatisticalDataSet.ancestors.include?(Edition::DocumentSeries)
  end

  test "specifically limit access" do
    data_set = build(:statistical_data_set, access_limited: true)
    assert data_set.access_limited?
  end

  test "specifically do not limit access" do
    data_set = build(:statistical_data_set, access_limited: false)
    refute data_set.access_limited?
  end

  test "limit access by default" do
    data_set = build(:statistical_data_set)
    assert data_set.access_limited?
  end
end