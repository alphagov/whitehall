require "test_helper"

class DocumentSeriesTest < ActiveSupport::TestCase
  should_protect_against_xss_and_content_attacks_on :name, :description

  test 'should be invalid without a name' do
    series = build(:document_series, name: nil)
    refute series.valid?
  end

  test 'should be associatable to editions' do
    series = create(:document_series)
    publication = create(:publication, document_series: [series])
    assert_equal [publication], series.editions
  end

  test 'published_editions should return only those editions who are published' do
    series = create(:document_series)
    draft_publication = create(:draft_publication, document_series: [series])
    published_publication = create(:published_publication, document_series: [series])
    assert_equal [published_publication], series.published_editions
  end

  test 'published_editions should be ordered by most recent publication date first' do
    series = create(:document_series)
    old_publication = create(:published_publication, document_series: [series], publication_date: 2.days.ago)
    new_publication = create(:published_publication, document_series: [series], publication_date: 1.day.ago)
    assert_equal [new_publication, old_publication], series.published_editions
  end

  test 'published_publications should return published publications' do
    series = create(:document_series)
    published_publication = create(:published_publication, document_series: [series])
    draft_publication = create(:draft_publication, document_series: [series])
    assert_equal [published_publication], series.published_publications
  end

  test 'published_statistical_data_sets should return published statistical data sets' do
    series = create(:document_series)
    published_statistical_data_set = create(:published_statistical_data_set, document_series: [series])
    draft_statistical_data_set = create(:draft_statistical_data_set, document_series: [series])
    assert_equal [published_statistical_data_set], series.published_statistical_data_sets
  end

  test 'should not be destroyable if editions are associated' do
    series = create(:document_series)
    publication = create(:draft_publication, document_series: [series])
    series.destroy
    assert DocumentSeries.find(series.id)
  end

  test "should exclude deleted document_series by default" do
    current_document_series = create(:document_series)
    deleted_document_series = create(:document_series, state: "deleted")
    assert_equal [current_document_series], DocumentSeries.all
  end

  test "should be deletable when there are no associated editions" do
    document_series = create(:document_series)
    assert document_series.destroyable?
    document_series.delete!
    assert document_series.deleted?
  end

  test "should generate a slug based on its name" do
    series = create(:document_series, name: 'The Best Series Ever')
    assert_equal 'the-best-series-ever', series.reload.slug
  end

  test "should not change the slug when the name is changed" do
    series = create(:document_series, name: 'The Best Series Ever')
    series.update_attributes(name: 'The Worst Series Ever')
    assert_equal 'the-best-series-ever', series.reload.slug
  end

  test "should not include apostrophes in slug" do
    series = create(:document_series, name: "Bob's bike")
    assert_equal 'bobs-bike', series.slug
  end
end
