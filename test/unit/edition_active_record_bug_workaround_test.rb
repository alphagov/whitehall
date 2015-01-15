require "test_helper"

class EditionActiveRecordBugWorkaroundTest < ActiveSupport::TestCase
  include ActionDispatch::TestProcess

  test "related_editions scope is not affected by calling Edition.related_to with other scopes" do
    policy = create(:published_policy)
    publications = [
      create(:published_publication, related_editions: [policy]),
      create(:draft_publication, related_editions: [policy])
    ]
    Edition.published.related_to(policy).load

    assert_equal publications, policy.related_editions
  end
end
