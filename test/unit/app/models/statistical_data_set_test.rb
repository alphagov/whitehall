require "test_helper"

class StatisticalDataSetTest < ActiveSupport::TestCase
  should_allow_inline_attachments

  test "should include the Edition::HasDocumentCollections behaviour" do
    assert StatisticalDataSet.ancestors.include?(Edition::HasDocumentCollections)
  end

  test "specifies rendering app to be frontend" do
    statistical_data_set = StatisticalDataSet.new
    assert statistical_data_set.rendering_app.include?(Whitehall::RenderingApp::FRONTEND)
  end
end
