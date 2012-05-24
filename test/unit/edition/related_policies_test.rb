require "test_helper"

class Edition::RelatedPoliciesTest < ActiveSupport::TestCase
  test "#destroy should also remove the relationship to existing policies" do
    document = create(:draft_consultation, related_policies: [create(:draft_policy)])
    relation = document.edition_relations.first
    document.destroy
    refute EditionRelation.find_by_id(relation.id)
  end
end