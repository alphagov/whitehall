require "test_helper"

class Document::MinistersTest < ActiveSupport::TestCase
  test "#destroy should also remove the relationship" do
    document = create(:draft_policy, ministerial_roles: [create(:ministerial_role)])
    relation = document.document_ministerial_roles.first
    document.destroy
    refute DocumentMinisterialRole.find_by_id(relation.id)
  end
end
