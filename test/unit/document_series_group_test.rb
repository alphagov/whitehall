require 'test_helper'

class DocumentSeriesGroupTest < ActiveSupport::TestCase
  test 'new groups should set #ordering when assigned to a series' do
    series = create(:document_series)
    series.groups << build(:document_series_group)
    series.groups << build(:document_series_group)
    assert_equal [1, 2], series.groups.reload.map(&:ordering)
  end

  test 'should list published editions' do
    group = create(:document_series_group)
    published = create(:published_publication)
    draft = create(:draft_publication)
    group.documents << [published.document, draft.document]
    assert_equal [published], group.published_editions
  end

  test 'should list latest editions in reverse chronological order, with drafts at the end' do
    group = create(:document_series_group)
    draft = create(:draft_publication)
    new = create(:published_publication, first_published_at: 1.day.ago)
    old = create(:published_publication, first_published_at: 2.days.ago)
    group.documents = [draft.document, new.document, old.document]
    assert_equal [new, old, draft], group.latest_editions
  end
end
