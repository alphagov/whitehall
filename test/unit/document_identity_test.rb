require 'test_helper'

class DocumentIdentityTest < ActiveSupport::TestCase
  test 'should return documents that have published documents' do
    archived_policy = create(:archived_policy)
    published_policy = create(:published_policy)
    draft_policy = create(:draft_policy)

    assert_equal [published_policy.document_identity], DocumentIdentity.published
  end

  test 'should return the published document' do
    document_identity = create(:document_identity)
    archived_policy = create(:archived_policy, document_identity: document_identity)
    published_policy = create(:published_policy, document_identity: document_identity)
    draft_policy = create(:draft_policy, document_identity: document_identity)

    assert_equal published_policy, document_identity.published_document
  end
end