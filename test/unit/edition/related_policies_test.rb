require "test_helper"

class Edition::RelatedPoliciesTest < ActiveSupport::TestCase
  test "#destroy should also remove the relationship to existing policies" do
    edition = create(:draft_consultation, related_editions: [create(:draft_policy)])
    relation = edition.edition_relations.first
    edition.destroy
    refute EditionRelation.find_by_id(relation.id)
  end

  class EditionWithRelatedPolicies < Edition
    include Edition::RelatedPolicies
  end

  FactoryGirl.define do
    factory :edition_with_related_policies, class: EditionWithRelatedPolicies, parent: :edition
  end

  test "search_index contains topics associated via policies" do
    edition = create(:edition_with_related_policies, related_editions: [create(:published_policy, topics: [create(:topic)])])

    edition.stubs(:public_document_path)
    assert_equal edition.topics.map(&:slug), edition.search_index['topics']

  end
end
