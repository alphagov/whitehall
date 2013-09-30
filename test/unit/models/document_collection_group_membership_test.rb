require 'test_helper'

class DocumentCollectionGroupMembershipTest < ActiveSupport::TestCase
  test 'maintain ordering of documents in a group' do
    group = create(:document_collection_group, document_collection: build(:document_collection))
    group.documents << build(:document)
    group.documents << build(:document)
    assert_equal [1, 2], group.memberships.reload.map(&:ordering)
  end
end
