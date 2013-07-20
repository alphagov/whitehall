require "test_helper"

class Edition::HasDocumentSeriesTest < ActiveSupport::TestCase

  test "should return search index suitable for Rummageable" do
    document_series = create(:document_series)
    edition = create(:published_statistical_data_set, document_series: [document_series])

    assert_equal [document_series.slug], edition.search_index["document_series"]
  end

  test "uses counter caching on the document_series association" do
    document_series = create(:document_series)
    edition = create(:published_statistical_data_set, document_series: [document_series])

    assert_equal 1, edition.document_series_count

    edition.document_series << create(:document_series)
    assert_equal 2, edition.document_series_count
  end
end
