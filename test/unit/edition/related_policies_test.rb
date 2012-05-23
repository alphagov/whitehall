require "test_helper"

class Edition::RelatedPoliciesTest < ActiveSupport::TestCase
  test "#destroy should also remove the relationship to existing policies" do
    document = create(:draft_consultation, related_policies: [create(:draft_policy)])
    relation = document.document_relations.first
    document.destroy
    refute DocumentRelation.find_by_id(relation.id)
  end
end