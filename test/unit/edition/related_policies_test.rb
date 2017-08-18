require "test_helper"

class Edition::RelatedPoliciesTest < ActiveSupport::TestCase
  test 'can assign, save and read content_ids for related policies' do
    edition = create(:news_article)
    edition.policy_content_ids = [policy_area_1.fetch("content_id")]

    assert_equal [policy_area_1.fetch("content_id")], edition.reload.policy_content_ids
  end

  test 're-assigning already-assigned content_ids does not create duplicates' do
    edition = create(:news_article, policy_content_ids: [policy_area_1.fetch("content_id")])

    assert_equal [policy_area_1.fetch("content_id")], edition.policy_content_ids

    edition.policy_content_ids = [policy_area_1.fetch("content_id"), policy_area_2.fetch("content_id")]

    assert_equal [policy_area_1.fetch("content_id"), policy_area_2.fetch("content_id")], edition.reload.policy_content_ids
  end

  test 'includes linked policies in search index data' do
    edition = create(:news_article)
    assert_equal [], edition.search_index[:policies]

    edition.policy_content_ids = [policy_area_1.fetch("content_id")]
    assert_equal ['policy-area-1'], edition.search_index[:policies]
  end

  test 'includes linked policies with parent policies in search index data' do
    edition = create(:news_article)
    assert_equal [], edition.search_index[:policies]

    edition.policy_content_ids = [policy_1.fetch("content_id")]
    assert_equal ['policy-area-1', 'policy-1'], edition.search_index[:policies]
  end

  test 'includes linked policies with multiple parents in search index data' do
    edition = create(:news_article)
    assert_equal [], edition.search_index[:policies]

    edition.policy_content_ids = [policy_2.fetch("content_id")]
    assert_equal ['policy-area-1', 'policy-area-2', 'policy-2'], edition.search_index[:policies]
  end

  test 'ignores non-existant content_ids' do
    nonexistant_policy_id = SecureRandom.uuid
    publishing_api_does_not_have_item(nonexistant_policy_id)
    publishing_api_does_not_have_links(nonexistant_policy_id)

    edition = create(:news_article, policy_content_ids: [nonexistant_policy_id, policy_area_1.fetch("content_id")])
    assert_equal ['policy-area-1'], edition.search_index[:policies]
  end

  test 'ignores non-existant parent policies' do
    edition = create(:news_article)

    WebMock.reset!

    publishing_api_does_not_have_item(policy_area_1.fetch("content_id"))
    publishing_api_does_not_have_links(policy_area_1.fetch("content_id"))

    publishing_api_has_linkables([policy_1], document_type: "policy")

    publishing_api_has_links(
      "content_id" => policy_1["content_id"],
      "links" => policy_1["links"],
    )

    assert_equal [], edition.search_index[:policies]

    edition.policy_content_ids = [policy_1.fetch("content_id")]
    assert_equal ['policy-1'], edition.search_index[:policies]
  end

  test '#policy_content_ids returns content_ids on an unsaved instance' do
    edition = NewsArticle.new(policy_content_ids: [policy_area_1.fetch("content_id")])
    assert_equal [policy_area_1.fetch("content_id")], edition.policy_content_ids
  end

  test 're-editioned documents maintain related policies' do
    edition = create(:published_news_article, policy_content_ids: [policy_area_1.fetch("content_id")])
    new_edition = edition.create_draft(create(:writer))

    assert_equal [policy_area_1.fetch("content_id")], new_edition.policy_content_ids
  end

  test "#policies returns policy objects, ignoring those that do not exist" do
    nonexistant_policy_id = SecureRandom.uuid
    publishing_api_does_not_have_item(nonexistant_policy_id)
    publishing_api_does_not_have_links(nonexistant_policy_id)

    policy = Policy.new(policy_area_1)
    edition = create(:news_article, policy_content_ids: [policy.content_id, nonexistant_policy_id])

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
      edition = create(document_with_policies, policy_content_ids: [policy_area_1.fetch("content_id")])

      assert_equal [policy_area_1.fetch("content_id")], edition.policy_content_ids

      edition.add_policy(policy_area_2.fetch("content_id"))

      assert_equal [policy_area_1.fetch("content_id"), policy_area_2.fetch("content_id")], edition.reload.policy_content_ids
    end

    test "can remove a policy by content id to a #{document_with_policies}" do
      edition = create(document_with_policies, policy_content_ids: [policy_area_1.fetch("content_id"), policy_area_2.fetch("content_id")])

      assert_equal [policy_area_1.fetch("content_id"), policy_area_2.fetch("content_id")], edition.policy_content_ids

      edition.delete_policy(policy_area_2.fetch("content_id"))

      assert_equal [policy_area_1.fetch("content_id")], edition.reload.policy_content_ids
    end
  end

  test "does not add a policy twice" do
    edition = create(:speech, policy_content_ids: [policy_area_1.fetch("content_id")])

    assert_equal [policy_area_1.fetch("content_id")], edition.policy_content_ids

    edition.add_policy(policy_area_2.fetch("content_id"))
    edition.add_policy(policy_area_2.fetch("content_id"))

    assert_equal [policy_area_1.fetch("content_id"), policy_area_2.fetch("content_id")], edition.reload.policy_content_ids
  end
end
