require "test_helper"

class Edition::NationInapplicabilityTest < ActiveSupport::TestCase
  test "#destroy should also remove the relationship" do
    edition = create(:draft_policy, nation_inapplicabilities_attributes: [{nation: Nation.potentially_inapplicable.first}])
    relation = edition.nation_inapplicabilities.first
    edition.destroy
    refute NationInapplicability.find_by_id(relation.id)
  end
end
