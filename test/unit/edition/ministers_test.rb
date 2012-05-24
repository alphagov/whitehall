require "test_helper"

class Edition::MinistersTest < ActiveSupport::TestCase
  test "#destroy should also remove the relationship" do
    document = create(:draft_policy, ministerial_roles: [create(:ministerial_role)])
    relation = document.edition_ministerial_roles.first
    document.destroy
    refute EditionMinisterialRole.find_by_id(relation.id)
  end
end
