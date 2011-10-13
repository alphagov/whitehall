require "test_helper"

class DocumentIdentityTest < ActiveSupport::TestCase
  test "sets a 6 character random key during initialization" do
    keys = 100.times.collect { DocumentIdentity.new.key }
    assert_equal 100, keys.compact.uniq.size
    assert_equal [8], keys.collect(&:length).uniq
    refute_equal keys.sort, keys
    refute_equal keys.sort.reverse, keys
  end

  test "doesn't allow key to change via setter" do
    identity = create(:document_identity)
    original_key = identity.key
    identity.key = "new-key"
    assert_equal original_key, identity.key
  end

  test "doesn't allow key to change via updating attributes" do
    identity = create(:document_identity)
    original_key = identity.key
    identity.update_attributes(key: "new-key")
    assert_equal original_key, identity.key
  end

  test "ensures chosen key is unique" do
    identity = create(:document_identity)
    DocumentIdentity.stubs(:random_key).returns(identity.key).then.returns("2nd-key")
    assert_equal "2nd-key", DocumentIdentity.new.key
  end

  test "should return documents that have published documents" do
    archived_policy = create(:archived_policy)
    published_policy = create(:published_policy)
    draft_policy = create(:draft_policy)

    assert_equal [published_policy.document_identity], DocumentIdentity.published
  end

  test "should return the published document" do
    document_identity = create(:document_identity)
    archived_policy = create(:archived_policy, document_identity: document_identity)
    published_policy = create(:published_policy, document_identity: document_identity)
    draft_policy = create(:draft_policy, document_identity: document_identity)

    assert_equal published_policy, document_identity.published_document
  end
end