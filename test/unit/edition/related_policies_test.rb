require "test_helper"

class Edition::RelatedPoliciesTest < ActiveSupport::TestCase
  include ContentRegisterHelpers

  test "#destroy should also remove the relationship to existing policies" do
    edition = create(:draft_consultation, related_editions: [create(:draft_policy)])
    relation = edition.outbound_edition_relations.first
    edition.destroy
    refute EditionRelation.exists?(relation.id)
  end

  test "can set the policies without removing the other documents" do
    edition = create(:world_location_news_article)
    worldwide_priority = create(:worldwide_priority)
    old_policy = create(:policy)
    edition.related_editions = [worldwide_priority, old_policy]

    new_policy = create(:policy)
    edition.related_policy_ids = [new_policy.id]
    assert_equal [worldwide_priority], edition.worldwide_priorities
    assert_equal [new_policy], edition.related_policies
  end

  test '#related_policy_ids returns the related policy ids for a persisted record' do
    policy = create(:policy)
    edition = create(:news_article, related_documents: [policy.document])

    assert_equal [policy.id], edition.related_policy_ids
  end

  test '#releated_policy_ids returns the related policy ids for a non-persisted record' do
    policy = create(:policy)
    edition = build(:news_article, related_documents: [policy.document])

    assert_equal [policy.id], edition.related_policy_ids
  end

  test '#related_policy_ids returns the related policy ids when set with the setter' do
    policy = create(:policy)
    edition = build(:news_article)
    edition.related_policy_ids = [policy.id]

    assert_equal [policy.id], edition.related_policy_ids
  end

  test '#related_policy_ids does not include non-policies' do
    policy = create(:policy)
    edition = create(:news_article,
      related_documents: [policy.document, create(:detailed_guide).document])

    assert_equal [policy.id], edition.related_policy_ids
  end

  test '#related_policy_ids does not fall over with deleted documents' do
    policy = create(:deleted_policy)
    edition = create(:news_article, related_documents: [policy.document])

    assert_equal [], edition.related_policy_ids
  end

  test 'can assign, save and read content_ids for related policies' do
    content_id = SecureRandom.uuid
    edition = create(:news_article)
    edition.policy_content_ids = [content_id]

    assert_equal [content_id], edition.reload.policy_content_ids
  end

  test 're-assigning already-assigned content_ids does not create duplicates' do
    content_id_1 = SecureRandom.uuid
    content_id_2 = SecureRandom.uuid
    edition = create(:news_article, policy_content_ids: [content_id_1])

    assert_equal [content_id_1], edition.policy_content_ids

    edition.policy_content_ids = [content_id_1, content_id_2]

    assert_equal [content_id_1, content_id_2], edition.reload.policy_content_ids
  end

  test 'includes linked policies in search index data' do
    stub_content_register_policies

    edition = create(:news_article)
    assert_equal [], edition.search_index[:policies]

    edition.policy_content_ids = [policy_1['content_id']]
    assert_equal ['policy-1'], edition.search_index[:policies]
  end

  test 'ignores non-existant content_ids' do
    stub_content_register_policies

    edition = create(:news_article, policy_content_ids: [SecureRandom.uuid, policy_2['content_id']])
    assert_equal ['policy-2'], edition.search_index[:policies]
  end

  test '#policy_content_ids returns content_ids on an unsaved instance' do
    stub_content_register_policies

    edition = NewsArticle.new(policy_content_ids: [policy_2['content_id']])
    assert_equal [policy_2['content_id']], edition.policy_content_ids
  end

  test 're-editioned documents maintain related policies' do
    stub_content_register_policies

    content_id = SecureRandom.uuid
    edition = create(:published_news_article, policy_content_ids: [content_id])
    new_edition = edition.create_draft(create(:policy_writer))

    assert_equal [content_id], new_edition.policy_content_ids
  end

  test "#policies returns future-policies, ignoring those that do not exist" do
    stub_content_register_policies

    future_policy = Future::Policy.new(policy_1)
    edition = create(:news_article, policy_content_ids: [future_policy.content_id, 'bogus-id'])

    assert_equal 1, edition.policies.size
    assert_equal future_policy.title, edition.policies[0].title
  end
end
