require 'test_helper'

class DocumentSeriesGroupMembershipTest < ActiveSupport::TestCase
  test 'maintain ordering of documents in a group' do
    group = create(:document_series_group, document_series: build(:document_series))
    group.documents << build(:document)
    group.documents << build(:document)
    assert_equal [1, 2], group.memberships.reload.map(&:ordering)
  end
end
