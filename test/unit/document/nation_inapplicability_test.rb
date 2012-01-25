require "test_helper"

class Document::NationInapplicabilityTest < ActiveSupport::TestCase
  test "#destroy should also remove the relationship" do
    document = create(:draft_policy, nation_inapplicabilities_attributes: [{nation: Nation.first}])
    relation = document.nation_inapplicabilities.first
    document.destroy
    refute NationInapplicability.find_by_id(relation.id)
  end
end
