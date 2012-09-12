require "test_helper"

class DocumentSeriesTest < ActiveSupport::TestCase
  test 'should be invalid without a name' do
    series = build(:document_series, name: nil)
    refute series.valid?
  end

  test 'should be associatable to editions' do
    series = create(:document_series)
    publication = create(:publication, document_series: series)
    assert_equal [publication], series.editions
  end

  test 'published_editions should return only those editions who are published' do
    series = create(:document_series)
    draft_publication = create(:draft_publication, document_series: series)
    published_publication = create(:published_publication, document_series: series)
    assert_equal [published_publication], series.published_editions
  end

  test 'published_editions should be ordered by most recent publication date first' do
    series = create(:document_series)
    old_publication = create(:published_publication, document_series: series, publication_date: 2.days.ago)
    new_publication = create(:published_publication, document_series: series, publication_date: 1.day.ago)
    assert_equal [new_publication, old_publication], series.published_editions
  end

  test 'should not be destroyable if editions are associated' do
    series = create(:document_series)
    publication = create(:draft_publication, document_series: series)
    series.destroy
    assert DocumentSeries.find(series.id)
  end
end
