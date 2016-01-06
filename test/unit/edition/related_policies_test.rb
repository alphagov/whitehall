require "test_helper"

class Edition::RelatedPoliciesTest < ActiveSupport::TestCase
  include ContentRegisterHelpers

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

  test 'includes linked policies with policy areas in search index data' do
    stub_content_register_policies_with_policy_areas

    edition = create(:news_article)
    assert_equal [], edition.search_index[:policies]

    edition.policy_content_ids = [policy_1['content_id']]
    assert_equal ['policy-area-1', 'policy-1'], edition.search_index[:policies]
  end

  test 'includes linked policies with multiple parents in search index data' do
    stub_content_register_policies_with_policy_areas

    edition = create(:news_article)
    assert_equal [], edition.search_index[:policies]

    edition.policy_content_ids = [policy_2['content_id']]
    assert_equal ['policy-area-1', 'policy-area-2', 'policy-2'], edition.search_index[:policies]
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
    new_edition = edition.create_draft(create(:writer))

    assert_equal [content_id], new_edition.policy_content_ids
  end

  test "#policies returns future-policies, ignoring those that do not exist" do
    stub_content_register_policies

    policy = Policy.new(policy_1)
    edition = create(:news_article, policy_content_ids: [policy.content_id, 'bogus-id'])

    assert_equal 1, edition.policies.size
    assert_equal policy.title, edition.policies[0].title
  end

  [:news_article,
   :document_collection,
   :consultation,
   :publication,
   :detailed_guide,
   :speech,
  ].each do |document_with_policies|
    test "can add a policy by content id to a #{document_with_policies}" do
      content_id_1 = SecureRandom.uuid
      content_id_2 = SecureRandom.uuid

      edition = create(document_with_policies, policy_content_ids: [content_id_1])

      assert_equal [content_id_1], edition.policy_content_ids

      edition.add_policy(content_id_2)

      assert_equal [content_id_1, content_id_2], edition.reload.policy_content_ids
    end

    test "can remove a policy by content id to a #{document_with_policies}" do
      content_id_1 = SecureRandom.uuid
      content_id_2 = SecureRandom.uuid
      edition = create(document_with_policies, policy_content_ids: [content_id_1, content_id_2])

      assert_equal [content_id_1, content_id_2], edition.policy_content_ids

      edition.delete_policy(content_id_2)

      assert_equal [content_id_1], edition.reload.policy_content_ids
    end
  end

  test "does not add a policy twice" do
    content_id_1 = SecureRandom.uuid
    content_id_2 = SecureRandom.uuid

    edition = create(:speech, policy_content_ids: [content_id_1])

    assert_equal [content_id_1], edition.policy_content_ids

    edition.add_policy(content_id_2)
    edition.add_policy(content_id_2)

    assert_equal [content_id_1, content_id_2], edition.reload.policy_content_ids
  end
end
