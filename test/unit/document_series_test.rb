require "test_helper"

class DocumentSeriesTest < ActiveSupport::TestCase
  should_protect_against_xss_and_content_attacks_on :name, :description

  test 'returns published editions from series in reverse chronological order' do
    series = create(:document_series, :with_group)
    draft = create(:draft_publication)
    old = create(:published_publication, first_published_at: 2.days.ago)
    new = create(:published_publication, first_published_at: 1.day.ago)
    group = series.groups.first
    group.documents = [draft.document, old.document, new.document]

    assert_equal [new, old], series.published_editions
  end

  test 'returns editions that are scheduled for publishing in the series' do
    series = create(:document_series, :with_group)
    publication = create(:published_publication, first_published_at: 2.days.ago)
    scheduled_publication = create(:scheduled_publication)
    group = series.groups.first
    group.documents = [scheduled_publication.document, publication.document]

    assert_equal [scheduled_publication], series.scheduled_editions
  end

  test 'is not deletable if published documents are associated with it' do
    series = create(:document_series, :with_group)
    group = series.groups.first
    group.documents = [create(:published_publication).document]
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
