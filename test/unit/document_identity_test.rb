require "test_helper"

class DocumentIdentityTest < ActiveSupport::TestCase
  test "should return documents that have published documents" do
    archived_policy = create(:archived_policy)
    published_policy = create(:published_policy)
    draft_policy = create(:draft_policy)

    assert_equal [published_policy.document_identity], DocumentIdentity.published
  end

  test "should return the published document" do
    user = create(:departmental_editor)
    document_identity = create(:document_identity)
    original_policy = create(:draft_policy, document_identity: document_identity)
    original_policy.publish_as(user, force: true)
    draft_policy = original_policy.create_draft(user)
    draft_policy.publish_as(user, force: true)

    archived_policy = original_policy
    published_policy = draft_policy
    new_draft_policy = published_policy.create_draft(user)

    assert_equal published_policy, document_identity.published_document
  end
end