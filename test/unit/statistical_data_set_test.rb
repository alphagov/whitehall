require "test_helper"

class StatisticalDataSetTest < ActiveSupport::TestCase
  should_allow_inline_attachments

  test "should include the Edition::HasDocumentCollections behaviour" do
    assert StatisticalDataSet.ancestors.include?(Edition::HasDocumentCollections)
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

  test 'search_format_types tags the data set as a statistical-data-set and publicationesque-statistics' do
    statistical_data_set = build(:statistical_data_set)
    assert statistical_data_set.search_format_types.include?('statistical-data-set')
    assert statistical_data_set.search_format_types.include?('publicationesque-statistics')
  end

  test 'specifies rendering app to be government frontend' do
    statistical_data_set = StatisticalDataSet.new
    assert statistical_data_set.rendering_app.include?(Whitehall::RenderingApp::GOVERNMENT_FRONTEND)
  end
end
