require "test_helper"

class Edition::HasDocumentSeriesTest < ActiveSupport::TestCase

  test "includes document series slugs in the search index data" do
    edition = create(:published_statistical_data_set)
    document_series = create(:document_series, documents: [edition.document])

    assert_equal [document_series.slug], edition.search_index["document_series"]
  end

  test '#part_of_series? returns true when its document is in a series' do
    edition = create(:published_publication)
    refute edition.part_of_series?

    series = create(:document_series, documents: [edition.document])
    assert edition.reload.part_of_series?
  end
end
