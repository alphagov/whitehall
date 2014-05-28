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

  test "#role_inactive_govuk_status_description for a role that no longer exists with no date" do
    role = create(:ministerial_role, status: "inactive", reason_for_inactivity: "no_longer_exists",  name: "Role name")
    assert_equal "Role name no longer exists", role_inactive_govuk_status_description(role)
  end

  test "#role_inactive_govuk_status_description for a role that no longer exists with a closure date" do
    role = create(:ministerial_role, status: "inactive", reason_for_inactivity: "no_longer_exists",  name: "Role name", date_of_inactivity: Date.parse("1 January 2014"))
    assert_equal "Role name no longer exists as of January 2014", role_inactive_govuk_status_description(role)
  end

  test "#role_inactive_govuk_status_description for a role that has been replaced with no date" do
    superseding_role = create(:ministerial_role, name: "Superseding role")
    role = create(:ministerial_role, status: "inactive", reason_for_inactivity: "replaced",  name: "Role name", superseding_roles: [superseding_role])
    assert_equal "Role name was replaced by <a href=\"/government/ministers/superseding-role\">Superseding role</a>", role_inactive_govuk_status_description(role)
  end

  test "#role_inactive_govuk_status_description for a role that has been replaced with a closure date" do
    superseding_role = create(:ministerial_role, name: "Superseding role")
    role = create(:ministerial_role, status: "inactive", reason_for_inactivity: "replaced",  name: "Role name", date_of_inactivity: Date.parse("1 January 2014"), superseding_roles: [superseding_role])
    assert_equal "Role name was replaced by <a href=\"/government/ministers/superseding-role\">Superseding role</a> in January 2014", role_inactive_govuk_status_description(role)
  end

  test "#role_inactive_govuk_status_description for a role that has split with no date" do
    superseding_role_1 = create(:ministerial_role, name: "Superseding role 1")
    superseding_role_2 = create(:ministerial_role, name: "Superseding role 2")
    role = create(:ministerial_role, status: "inactive", reason_for_inactivity: "split",  name: "Role name", superseding_roles: [superseding_role_1, superseding_role_2])
    assert_equal "Role name was split into <a href=\"/government/ministers/superseding-role-1\">Superseding role 1</a> and <a href=\"/government/ministers/superseding-role-2\">Superseding role 2</a>", role_inactive_govuk_status_description(role)
  end

  test "#role_inactive_govuk_status_description for a role that has split with a closure date" do
    superseding_role_1 = create(:ministerial_role, name: "Superseding role 1")
    superseding_role_2 = create(:ministerial_role, name: "Superseding role 2")
    role = create(:ministerial_role, status: "inactive", reason_for_inactivity: "split",  name: "Role name", date_of_inactivity: Date.parse("1 January 2014"), superseding_roles: [superseding_role_1, superseding_role_2])
    assert_equal "Role name was split into <a href=\"/government/ministers/superseding-role-1\">Superseding role 1</a> and <a href=\"/government/ministers/superseding-role-2\">Superseding role 2</a> in January 2014", role_inactive_govuk_status_description(role)
  end

  test "#role_inactive_govuk_status_description for a role that has been merged with no date" do
    superseding_role = create(:ministerial_role, name: "Superseding role")
    role = create(:ministerial_role, status: "inactive", reason_for_inactivity: "merged",  name: "Role name", superseding_roles: [superseding_role])
    assert_equal "Role name was merged into <a href=\"/government/ministers/superseding-role\">Superseding role</a>", role_inactive_govuk_status_description(role)
  end

  test "#role_inactive_govuk_status_description for a role that has been merged with a closure date" do
    superseding_role = create(:ministerial_role, name: "Superseding role")
    role = create(:ministerial_role, status: "inactive", reason_for_inactivity: "merged",  name: "Role name", date_of_inactivity: Date.parse("1 January 2014"), superseding_roles: [superseding_role])
    assert_equal "Role name was merged into <a href=\"/government/ministers/superseding-role\">Superseding role</a> in January 2014", role_inactive_govuk_status_description(role)
  end

end
