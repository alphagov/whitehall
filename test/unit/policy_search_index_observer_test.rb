require 'test_helper'

class PolicySearchIndexObserverTest < ActiveSupport::TestCase
  test 'should re-index all editions that are related to this policy when the policy is published' do
    policy = create(:submitted_policy)
    publication = create(:published_publication, related_editions: [policy])
    policy.stubs(:published_related_editions).returns([publication])
    publication.expects(:update_in_search_index)

    policy.publish_as(create(:departmental_editor))
  end

  test 'should re-index all editions that are related when the policy is unpublished' do
    policy = create(:published_policy)
    publication = create(:published_publication, related_editions: [policy])
    policy.stubs(:published_related_editions).returns([publication])
    publication.expects(:update_in_search_index)
    policy.reload
    policy.unpublish_as(create(:gds_editor))
  end
end
