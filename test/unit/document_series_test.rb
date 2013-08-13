require "test_helper"

class DocumentSeriesTest < ActiveSupport::TestCase
  should_protect_against_xss_and_content_attacks_on :name, :description

  test '#published_editions returns published editions in reverse chronological order' do
    series = create(:document_series)
    draft_publication = create(:draft_publication)
    old_publication = create(:published_publication, publication_date: 2.days.ago)
    new_publication = create(:published_publication, publication_date: 1.day.ago)
    series.documents = [draft_publication.document, old_publication.document, new_publication.document]

    assert_equal [new_publication, old_publication], series.published_editions
  end

  test '#latest_editions returns all the latest editions of associated documents in reverse chronological order' do
    series = create(:document_series)
    old_publication = create(:published_publication, publication_date: 2.days.ago)
    draft_publication = create(:draft_publication)
    new_publication = create(:published_publication, publication_date: 1.day.ago)
    series.documents = [draft_publication.document, old_publication.document, new_publication.document]

    assert_equal [new_publication, old_publication, draft_publication], series.latest_editions
  end

  test '#scheduled_editions returns any editions that are scheduled for publishing' do
    series = create(:document_series)
    publication = create(:published_publication, publication_date: 2.days.ago)
    scheduled_publication = create(:scheduled_publication)
    series.documents = [scheduled_publication.document, publication.document]

    assert_equal [scheduled_publication], series.scheduled_editions
  end

  test 'is not deletable if published documents are associated with it' do
    series = create(:document_series, documents: [create(:published_publication).document])
    refute series.destroyable?
    series.delete!
    assert DocumentSeries.find(series.id)
  end

  test 'is deletable if only archived editions are associated' do
    series = create(:document_series, documents: [create(:archived_publication).document])
    assert series.destroyable?
    series.delete!
    assert series.deleted?
  end

  test "is deletable when there are no associated editions" do
    series = create(:document_series)
    assert series.destroyable?
    series.delete!
    assert series.deleted?
  end

  test "includes slug in search index data" do
    series = create(:document_series, name: "Coffee for the win")
    assert_equal 'coffee-for-the-win', series.search_index['slug']
  end

  test "indexes the description without markup" do
    series = create(:document_series, name: "A doc series", description: "This is a *description*")
    assert_equal "This is a description", series.search_index["indexable_content"]
  end
end
