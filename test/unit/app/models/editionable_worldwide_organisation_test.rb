require "test_helper"

class EditionableWorldwideOrganisationTest < ActiveSupport::TestCase
  test "can be associated with one or more worldwide offices" do
    worldwide_organisation = create(:editionable_worldwide_organisation)
    worldwide_office = create(:worldwide_office)
    worldwide_organisation.offices << worldwide_office

    assert_equal [worldwide_office], worldwide_organisation.offices
  end

  test "destroys associated worldwide offices" do
    worldwide_organisation = create(:editionable_worldwide_organisation)
    worldwide_office = create(:worldwide_office)
    worldwide_organisation.offices << worldwide_office

    worldwide_organisation.destroy!

    assert_equal 0, worldwide_organisation.offices.count
  end

  test "should set an analytics identifier on create" do
    worldwide_organisation = create(:editionable_worldwide_organisation)
    assert_equal "WO#{worldwide_organisation.id}", worldwide_organisation.analytics_identifier
  end

  test "an ambassadorial role is a primary role and not a secondary one" do
    worldwide_organisation = create(:editionable_worldwide_organisation)

    assert_nil worldwide_organisation.primary_role

    ambassador_role = create(:ambassador_role, :occupied)
    worldwide_organisation.roles << ambassador_role

    assert_equal ambassador_role, worldwide_organisation.primary_role
    assert_nil worldwide_organisation.secondary_role
  end

  test "a high commissioner role is a primary role and not a secondary one" do
    worldwide_organisation = create(:editionable_worldwide_organisation)

    assert_nil worldwide_organisation.primary_role

    high_commissioner_role = create(:high_commissioner_role, :occupied)
    worldwide_organisation.roles << high_commissioner_role

    assert_equal high_commissioner_role, worldwide_organisation.primary_role
    assert_nil worldwide_organisation.secondary_role
  end

  test "a governor role is a primary role and not a secondary one" do
    worldwide_organisation = create(:editionable_worldwide_organisation)

    assert_nil worldwide_organisation.primary_role

    governor_role = create(:governor_role, :occupied)
    worldwide_organisation.roles << governor_role

    assert_equal governor_role, worldwide_organisation.primary_role
    assert_nil worldwide_organisation.secondary_role
  end

  test "a deputy head of mission is second in charge and not a primary one" do
    worldwide_organisation = create(:editionable_worldwide_organisation)

    assert_nil worldwide_organisation.secondary_role

    deputy_role = create(:deputy_head_of_mission_role, :occupied)
    worldwide_organisation.roles << deputy_role

    assert_equal deputy_role, worldwide_organisation.secondary_role
    assert_nil worldwide_organisation.primary_role
  end

  test "office_staff_roles returns worldwide office staff roles" do
    worldwide_organisation = create(:editionable_worldwide_organisation)

    assert_equal [], worldwide_organisation.office_staff_roles

    staff_role1 = create(:worldwide_office_staff_role, :occupied)
    staff_role2 = create(:worldwide_office_staff_role, :occupied)
    worldwide_organisation.roles << staff_role1
    worldwide_organisation.roles << staff_role2

    assert_equal [staff_role1, staff_role2], worldwide_organisation.office_staff_roles
    assert_nil worldwide_organisation.primary_role
    assert_nil worldwide_organisation.secondary_role
  end

  test "primary, secondary and office staff roles return occupied roles only" do
    worldwide_organisation = create(:editionable_worldwide_organisation)

    worldwide_organisation.roles << create(:ambassador_role, :vacant)
    worldwide_organisation.roles << create(:deputy_head_of_mission_role, :vacant)
    worldwide_organisation.roles << create(:worldwide_office_staff_role, :vacant)

    assert_nil worldwide_organisation.primary_role
    assert_nil worldwide_organisation.secondary_role
    assert_equal [], worldwide_organisation.office_staff_roles

    a = create(:ambassador_role, :occupied)
    b = create(:deputy_head_of_mission_role, :occupied)
    c = create(:worldwide_office_staff_role, :occupied)
    worldwide_organisation.roles << a
    worldwide_organisation.roles << b
    worldwide_organisation.roles << c

    assert_equal a, worldwide_organisation.primary_role
    assert_equal b, worldwide_organisation.secondary_role
    assert_equal [c], worldwide_organisation.office_staff_roles
  end

  test "should clone social media associations when new draft of published edition is created" do
    published_worldwide_organisation = create(
      :editionable_worldwide_organisation,
      :published,
      :with_social_media_account,
    )

    draft_worldwide_organisation = published_worldwide_organisation.create_draft(create(:writer))

    assert_equal published_worldwide_organisation.social_media_accounts.first.title, draft_worldwide_organisation.social_media_accounts.first.title
    assert_equal published_worldwide_organisation.social_media_accounts.first.url, draft_worldwide_organisation.social_media_accounts.first.url
  end
end
