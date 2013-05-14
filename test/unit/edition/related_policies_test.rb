require "test_helper"

class Edition::RelatedPoliciesTest < ActiveSupport::TestCase
  test "#destroy should also remove the relationship to existing policies" do
    edition = create(:draft_consultation, related_editions: [create(:draft_policy)])
    relation = edition.outbound_edition_relations.first
    edition.destroy
    refute EditionRelation.exists?(relation.id)
  end

  class EditionWithRelatedPolicies < GenericEdition
    include Edition::RelatedPolicies
  end

  FactoryGirl.define do
    factory :edition_with_related_policies, class: EditionWithRelatedPolicies, parent: :edition
  end

  test "search_index contains topics associated via policies" do
    edition = create(:edition_with_related_policies, related_editions: [create(:published_policy, topics: [create(:topic)])])

    # TODO: Would return "edition" otherwise and that doesn't exist
    Whitehall.url_maker.stubs(:model_name_for_route_recognition).with(edition).returns('generic_edition')

    assert_equal edition.topics.map(&:slug), edition.search_index['topics']
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
end
