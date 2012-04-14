require "test_helper"

class PolicyTest < ActiveSupport::TestCase

  test "does not allow attachment" do
    refute build(:policy).allows_attachments?
  end

  test "should not be valid without a summary" do
    refute build(:policy, summary: nil).valid?
  end

  test "should build a draft copy of the existing policy with inapplicable nations" do
    published_policy = create(:published_policy, nation_inapplicabilities_attributes: [
      {nation: Nation.wales, alternative_url: "http://wales.gov.uk"},
      {nation: Nation.scotland, alternative_url: "http://scot.gov.uk"}]
    )

    draft_policy = published_policy.create_draft(create(:policy_writer))

    assert_equal published_policy.inapplicable_nations, draft_policy.inapplicable_nations
    assert_equal "http://wales.gov.uk", draft_policy.nation_inapplicabilities.find_by_nation_id(Nation.wales.id).alternative_url
    assert_equal "http://scot.gov.uk", draft_policy.nation_inapplicabilities.find_by_nation_id(Nation.scotland.id).alternative_url
  end

  test "should build a draft copy with references to related documents" do
    published_policy = create(:published_policy)
    publication = create(:published_publication, related_policies: [published_policy])
    speech = create(:published_speech, related_policies: [published_policy])

    draft_policy = published_policy.create_draft(create(:policy_writer))
    assert draft_policy.valid?

    assert draft_policy.related_documents.include?(speech)
    assert draft_policy.related_documents.include?(publication)
  end

  test "can belong to multiple policy topics" do
    policy_topic_1 = create(:policy_topic)
    policy_topic_2 = create(:policy_topic)
    policy = create(:policy, policy_topics: [policy_topic_1, policy_topic_2])
    assert_equal [policy_topic_1, policy_topic_2], policy.policy_topics.reload
  end

  test "prepends stub signifier to stub policy titles" do
    assert_equal "[Sample] stub title", build(:policy, title: "stub title", stub: true).title
  end

  test "stub status doesn't affect slug generation" do
    assert_equal "stub-title", create(:policy, title: "stub title", stub: true).doc_identity.slug
  end

  test "#destroy should remove document relations to other documents" do
    document = create(:draft_policy)
    relationship = create(:document_relation, doc_identity: document.doc_identity)
    document.destroy
    assert_equal nil, DocumentRelation.find_by_id(relationship.id)
  end
end
