require "test_helper"

class EditionableWorldwideOrganisationTest < ActiveSupport::TestCase
  test "can be associated with one or more worldwide offices" do
    worldwide_organisation = create(:editionable_worldwide_organisation)
    worldwide_office = create(:worldwide_office, worldwide_organisation: nil, edition: worldwide_organisation)

    assert_equal [worldwide_office], worldwide_organisation.offices
  end

  test "destroys associated worldwide offices" do
    worldwide_organisation = create(:editionable_worldwide_organisation)
    worldwide_office = create(:worldwide_office)
    worldwide_organisation.offices << worldwide_office

    worldwide_organisation.destroy!

    assert_equal 0, worldwide_organisation.offices.count
  end

  test "should be be valid without taxons" do
    worldwide_organisation = build(:draft_editionable_worldwide_organisation)
    assert worldwide_organisation.valid?
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

  test "should clone office and contact associations when new draft of published edition is created" do
    contact = create(:contact, translated_into: [:es])
    published_worldwide_organisation = create(:editionable_worldwide_organisation, :published)
    create(:worldwide_office, worldwide_organisation: nil, edition: published_worldwide_organisation, contact:)

    draft_worldwide_organisation = published_worldwide_organisation.create_draft(create(:writer))
    published_worldwide_organisation.reload

    assert_equal published_worldwide_organisation.offices.first.attributes.except("id", "edition_id"),
                 draft_worldwide_organisation.offices.first.attributes.except("id", "edition_id")
    assert_equal published_worldwide_organisation.offices.first.contact.attributes.except("id", "contactable_id"),
                 draft_worldwide_organisation.offices.first.contact.attributes.except("id", "contactable_id")
    assert_equal published_worldwide_organisation.main_office.attributes.except("id", "edition_id"),
                 draft_worldwide_organisation.main_office.attributes.except("id", "edition_id")
    assert_equal published_worldwide_organisation.offices.first.contact.translations.find_by(locale: :es).attributes.except("id", "contact_id"),
                 draft_worldwide_organisation.offices.first.contact.translations.find_by(locale: :es).attributes.except("id", "contact_id")
    assert_equal published_worldwide_organisation.offices.first.contact.translations.find_by(locale: :en).attributes.except("id", "contact_id"),
                 draft_worldwide_organisation.offices.first.contact.translations.find_by(locale: :en).attributes.except("id", "contact_id")
  end

  test "when destroyed, will remove its home page list for storing offices" do
    world_organisation = create(:editionable_worldwide_organisation)
    h = world_organisation.__send__(:home_page_offices_list)
    world_organisation.destroy!
    assert_not HomePageList.exists?(h.id)
  end

  test "has an overridable default main office" do
    worldwide_organisation = create(:editionable_worldwide_organisation)

    assert_nil worldwide_organisation.main_office

    office1 = create(:worldwide_office, worldwide_organisation: nil, edition: worldwide_organisation)
    assert_equal office1, worldwide_organisation.main_office

    office2 = create(:worldwide_office, worldwide_organisation: nil, edition: worldwide_organisation)
    worldwide_organisation.offices << office2
    assert_equal office1, worldwide_organisation.main_office

    worldwide_organisation.main_office = office2
    assert_equal office2, worldwide_organisation.main_office
  end

  test "distinguishes between the main office and other offices" do
    offices = [build(:worldwide_office), build(:worldwide_office)]
    worldwide_organisation = build(:editionable_worldwide_organisation, offices:, main_office: offices.last)

    assert worldwide_organisation.is_main_office?(offices.last)
    assert_not worldwide_organisation.is_main_office?(offices.first)
  end

  test "can list other offices" do
    offices = [build(:worldwide_office), build(:worldwide_office)]

    assert_equal [], build(:editionable_worldwide_organisation, offices: []).other_offices
    assert_equal [], build(:editionable_worldwide_organisation, offices: offices.take(1)).other_offices
    assert_equal [offices.last], build(:editionable_worldwide_organisation, offices:, main_office: offices.first).other_offices
  end

  test "knows if a given office is on its home page" do
    world_organisation = build(:editionable_worldwide_organisation)
    office = build(:worldwide_office, worldwide_organisation: nil)
    h = build(:home_page_list)
    HomePageList.stubs(:get).returns(h)
    h.expects(:shown_on_home_page?).with(office).returns :the_answer

    assert_equal :the_answer, world_organisation.office_shown_on_home_page?(office)
  end

  test "knows that the main office is on the home page, even if it's not explicitly in the list" do
    world_organisation = create(:editionable_worldwide_organisation)
    office1 = create(:worldwide_office, worldwide_organisation: nil, edition: world_organisation)
    office2 = create(:worldwide_office, worldwide_organisation: nil, edition: world_organisation)
    world_organisation.add_office_to_home_page!(office1)
    world_organisation.main_office = office2

    assert world_organisation.office_shown_on_home_page?(office2)
  end

  test "has a list of offices that are on its home page" do
    world_organisation = build(:editionable_worldwide_organisation)
    h = build(:home_page_list)
    HomePageList.stubs(:get).returns(h)
    h.expects(:items).returns [:the_list_of_offices]

    assert_equal [:the_list_of_offices], world_organisation.home_page_offices
  end

  test "the list of offices that are on its home page excludes the main office" do
    world_organisation = create(:editionable_worldwide_organisation)
    office1 = create(:worldwide_office, worldwide_organisation: nil, edition: world_organisation)
    office2 = create(:worldwide_office, worldwide_organisation: nil, edition: world_organisation)
    office3 = create(:worldwide_office, worldwide_organisation: nil, edition: world_organisation)
    world_organisation.add_office_to_home_page!(office1)
    world_organisation.add_office_to_home_page!(office2)
    world_organisation.add_office_to_home_page!(office3)
    world_organisation.main_office = office2

    assert_equal [office1, office3], world_organisation.home_page_offices
  end

  test "can add a office to the list of those that are on its home page" do
    world_organisation = build(:editionable_worldwide_organisation)
    office = build(:worldwide_office)
    h = build(:home_page_list)
    HomePageList.stubs(:get).returns(h)
    h.expects(:add_item).with(office).returns :a_result

    assert_equal :a_result, world_organisation.add_office_to_home_page!(office)
  end

  test "can remove a office from the list of those that are on its home page" do
    world_organisation = build(:editionable_worldwide_organisation)
    office = build(:worldwide_office)
    h = build(:home_page_list)
    HomePageList.stubs(:get).returns(h)
    h.expects(:remove_item).with(office).returns :a_result

    assert_equal :a_result, world_organisation.remove_office_from_home_page!(office)
  end

  test "can reorder the contacts on the list" do
    world_organisation = build(:editionable_worldwide_organisation)
    office1 = build(:worldwide_office)
    office2 = build(:worldwide_office)
    h = build(:home_page_list)
    HomePageList.stubs(:get).returns(h)
    h.expects(:reorder_items!).with([office1, office2]).returns :a_result

    assert_equal :a_result, world_organisation.reorder_offices_on_home_page!([office1, office2])
  end

  test "maintains a home page list for storing offices" do
    world_organisation = build(:editionable_worldwide_organisation)
    HomePageList.expects(:get).with(has_entries(owned_by: world_organisation, called: "offices")).returns :a_home_page_list_of_offices
    assert_equal :a_home_page_list_of_offices, world_organisation.__send__(:home_page_offices_list)
  end
end
