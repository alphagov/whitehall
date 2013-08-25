require 'test_helper'

class DocumentSeriesGroupTest < ActiveSupport::TestCase
  test 'new groups should set #ordering when assigned to a series' do
    series = create(:document_series)
    series.groups << build(:document_series_group)
    series.groups << build(:document_series_group)
    assert_equal [1, 2], series.groups.reload.map(&:ordering)
  end

  test 'a group should return its published editions' do
    group = create(:document_series_group)
    published = create(:published_publication)
    draft = create(:draft_publication)
    group.documents << [published.document, draft.document]
    assert_equal [published], group.published_editions
  end
end
