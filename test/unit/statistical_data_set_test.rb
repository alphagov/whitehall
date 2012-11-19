require "test_helper"

class StatisticalDataSetTest < EditionTestCase
  should_allow_inline_attachments
  should_allow_a_summary_to_be_written

  test "should include the Edition::DocumentSeries behaviour" do
    assert StatisticalDataSet.ancestors.include?(Edition::DocumentSeries)
  end

  test "access to it can be limited" do
    data_set = build(:statistical_data_set)
    assert data_set.can_limit_access?
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

  test "do not limit access to existing data set which did not have access limited set" do
    data_set = create(:statistical_data_set)
    data_set.update_column(:access_limited, nil)
    data_set.reload
    refute data_set.access_limited?
  end
end