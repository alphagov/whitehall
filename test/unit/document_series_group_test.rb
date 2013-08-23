require 'test_helper'

class DocumentSeriesGroupTest < ActiveSupport::TestCase
  test 'new groups should set #ordering when assigned to a series' do
    series = create(:document_series)
    series.groups << build(:document_series_group)
    series.groups << build(:document_series_group)
    assert_equal [1, 2], series.groups.reload.map(&:ordering)
  end
end
