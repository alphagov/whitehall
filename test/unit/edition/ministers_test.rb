require "test_helper"

class Edition::MinistersTest < ActiveSupport::TestCase
  test "#destroy should also remove the relationship" do
    edition = create(:draft_policy, ministerial_roles: [create(:ministerial_role)])
    relation = edition.edition_ministerial_roles.first
    edition.destroy
    refute EditionMinisterialRole.find_by_id(relation.id)
  end
end
