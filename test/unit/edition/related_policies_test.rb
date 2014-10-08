require "test_helper"

class Edition::RelatedPoliciesTest < ActiveSupport::TestCase
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
end
