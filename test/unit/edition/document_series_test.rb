require "test_helper"

class Edition::DocumentSeriesTest < ActiveSupport::TestCase

  test "should return search index suitable for Rummageable" do
    document_series = create(:document_series)
    edition = create(:published_statistical_data_set, document_series: [document_series])

    assert_equal [document_series.slug], edition.search_index["document_series"]
  end
end
