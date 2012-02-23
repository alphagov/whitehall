require 'test_helper'

class MinisterialRolesHelperTest < ActionView::TestCase
  test "#ministerial_role_organisation_class returns the slug of the organisation if role has single organisation" do
    organisations = [create(:organisation)]
    role = create(:role, organisations: organisations)
    assert_equal organisations.first.slug, ministerial_role_organisation_class(role)
  end

  test "#ministerial_role_organisation_class returns 'multiple_organisations' if role has multiple organisations" do
    organisations = [create(:organisation), create(:organisation)]
    role = create(:role, organisations: organisations)
    assert_equal 'multiple_organisations', ministerial_role_organisation_class(role)
  end
end