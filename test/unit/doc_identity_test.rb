require "test_helper"

class DocIdentityTest < ActiveSupport::TestCase
  test "should return documents that have published documents" do
    archived_policy = create(:archived_policy)
    published_policy = create(:published_policy)
    draft_policy = create(:draft_policy)

    assert_equal [published_policy.doc_identity], DocIdentity.published
  end

  test "should return the published document" do
    user = create(:departmental_editor)
    doc_identity = create(:doc_identity)
    original_policy = create(:draft_policy, doc_identity: doc_identity)
    original_policy.publish_as(user, force: true)
    draft_policy = original_policy.create_draft(user)
    draft_policy.change_note = "change-note"
    draft_policy.publish_as(user, force: true)

    archived_policy = original_policy
    published_policy = draft_policy
    new_draft_policy = published_policy.create_draft(user)

    assert_equal published_policy, doc_identity.reload.published_document
  end

  test "should be published if a published edition exists" do
    published_policy = create(:published_policy)
    assert published_policy.doc_identity.published?
  end

  test "should not be published if no published edition exists" do
    draft_policy = create(:draft_policy)
    refute draft_policy.doc_identity.published?
  end

  test "should ignore deleted editions when finding latest edition" do
    original_edition = create(:published_document)
    new_draft = original_edition.create_draft(create(:policy_writer))
    new_draft.delete!
    assert_equal original_edition, original_edition.doc_identity.latest_edition
  end

  test "#destroy also destroys ALL documents including those marked as deleted" do
    original_edition = create(:published_policy)
    new_draft = original_edition.create_draft(create(:policy_writer))
    new_draft.delete!
    original_edition.doc_identity.destroy
    assert_equal nil, Document.unscoped.find_by_id(original_edition.id)
    assert_equal nil, Document.unscoped.find_by_id(new_draft.id)
  end

  test "#destroy also destroys relations to other documents" do
    identity = create(:doc_identity)
    relationship = create(:document_relation, doc_identity: identity)
    identity.destroy
    assert_equal nil, DocumentRelation.find_by_id(relationship.id)
  end

  test "#destroy also destroys related consultation responses" do
    consultation = create(:published_consultation)
    consultation_response = create(:published_consultation_response, consultation: consultation)
    identity = consultation.doc_identity
    identity.destroy
    refute ConsultationResponse.find_by_id(consultation_response.id)
  end
end
