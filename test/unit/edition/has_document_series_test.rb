require "test_helper"

class Edition::HasDocumentSeriesTest < ActiveSupport::TestCase

  test "includes document series slugs in the search index data" do
    edition = create(:published_statistical_data_set)
    series = create(:document_series, :with_group)
    series.groups.first.documents = [edition.document]
    assert_equal [series.slug], edition.search_index["document_series"]
  end

  test '#part_of_series? returns true when its document is in a series' do
    edition = create(:published_publication)
    refute edition.part_of_series?

    series = create(:document_series, :with_group)
    series.groups.first.documents = [edition.document]
    assert edition.reload.part_of_series?
  end

  test 'allows assignment of document series on a saved edition' do
    edition = create(:imported_publication)
    document_series = create(:document_series, :with_group)
    edition.document_series_group_ids = [document_series.groups.first.id]
    assert_equal [document_series], edition.document.document_series
  end

  test 'raises an exception if attempt is made to set document series on a new edition' do
    series = create(:document_series, :with_group)
    assert_raise(StandardError) do
      Publication.new(document_series_group_ids: [series.groups.first.id])
    end
  end
end
