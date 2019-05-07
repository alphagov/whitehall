require 'test_helper'

class WorldwideOrganisationTest < ActiveSupport::TestCase
  should_protect_against_xss_and_content_attacks_on :name

  test "should set a slug from the field name" do
    worldwide_organisation = create(:worldwide_organisation, name: 'Office Name')
    assert_equal 'office-name', worldwide_organisation.slug
  end

  test 'should set an analytics identifier on create' do
    worldwide_organisation = create(:worldwide_organisation, name: 'Office name')
    assert_equal 'WO' + worldwide_organisation.id.to_s, worldwide_organisation.analytics_identifier
  end

  test 'can be associated with multiple world locations' do
    countries = [
      create(:world_location, name: 'France'),
      create(:world_location, name: 'Spain')
    ]
    worldwide_organisation = create(:worldwide_organisation, name: 'Office Name', world_locations: countries)

    assert_equal countries.sort_by(&:name), worldwide_organisation.world_locations.sort_by(&:name)
  end

  test "can be associated with one or more sponsoring organisations" do
    organisation = create(:organisation)
    worldwide_organisation = create(:worldwide_organisation)
    worldwide_organisation.sponsoring_organisations << organisation

    assert_equal [organisation], worldwide_organisation.reload.sponsoring_organisations
  end

  test "has a main sponsoring organisation" do
    organisation = create(:organisation)
    worldwide_organisation = create(:worldwide_organisation)
    worldwide_organisation.sponsoring_organisations << organisation
    worldwide_organisation.sponsoring_organisations << create(:organisation)

    assert_equal organisation, worldwide_organisation.reload.sponsoring_organisation
  end

  test 'can have a default news article image' do
    image = build(:default_news_organisation_image_data)
    worldwide_organisation = build(:worldwide_organisation, default_news_image: image)
    assert_equal image, worldwide_organisation.default_news_image
  end

  test "destroys associated sponsorships" do
    worldwide_organisation = create(:worldwide_organisation, sponsoring_organisations: [create(:organisation)])
    worldwide_organisation.destroy
    assert_equal 0, worldwide_organisation.sponsorships.count
  end

  test "destroys associated role appointments" do
    worldwide_organisation = create(:worldwide_organisation, worldwide_organisation_roles: [create(:worldwide_organisation_role)])
    worldwide_organisation.destroy
    assert_equal 0, worldwide_organisation.worldwide_organisation_roles.count
  end

  test "destroys associated office access information" do
    worldwide_organisation = create(:worldwide_organisation)
    office_access_info = create(:access_and_opening_times, accessible: worldwide_organisation)
    worldwide_organisation.destroy
    assert_not AccessAndOpeningTimes.exists?(office_access_info.id)
  end

  test 'destroys associated corporate information page documents and editions' do
    worldwide_organisation = create(:worldwide_organisation)
    create(:corporate_information_page, worldwide_organisation: worldwide_organisation, organisation: nil)

    assert_difference %w(WorldwideOrganisation.count Document.count CorporateInformationPage.count), -1 do
      worldwide_organisation.destroy
    end
  end

  test "has an overridable default main office" do
    worldwide_organisation = create(:worldwide_organisation)

    assert_nil worldwide_organisation.main_office

    office_1 = create(:worldwide_office)
    worldwide_organisation.offices << office_1
    assert_equal office_1, worldwide_organisation.main_office

    office_2 = create(:worldwide_office)
    worldwide_organisation.offices << office_2
    assert_equal office_1, worldwide_organisation.main_office

    worldwide_organisation.main_office = office_2
    assert_equal office_2, worldwide_organisation.main_office
  end

  test "distinguishes between the main office and other offices" do
    offices = [build(:worldwide_office), build(:worldwide_office)]
    worldwide_organisation = build(:worldwide_organisation, offices: offices, main_office: offices.last)

    assert worldwide_organisation.is_main_office?(offices.last)
    assert_not worldwide_organisation.is_main_office?(offices.first)
  end

  test "can list other offices" do
    offices = [build(:worldwide_office), build(:worldwide_office)]

    assert_equal [], build(:worldwide_organisation, offices: []).other_offices
    assert_equal [], build(:worldwide_organisation, offices: offices.take(1)).other_offices
    assert_equal [offices.last], build(:worldwide_organisation, offices: offices, main_office: offices.first).other_offices
  end

  test "an ambassadorial role is a primary role and not a secondary one" do
    worldwide_organisation = create(:worldwide_organisation)

    assert_nil worldwide_organisation.primary_role

    ambassador_role = create(:ambassador_role, :occupied, worldwide_organisations: [worldwide_organisation])

    assert_equal ambassador_role, worldwide_organisation.primary_role
    assert_nil worldwide_organisation.secondary_role
  end

  test "a high commissioner role is a primary role and not a secondary one" do
    worldwide_organisation = create(:worldwide_organisation)

    assert_nil worldwide_organisation.primary_role

    high_commissioner_role = create(:high_commissioner_role, :occupied, worldwide_organisations: [worldwide_organisation])

    assert_equal high_commissioner_role, worldwide_organisation.primary_role
    assert_nil worldwide_organisation.secondary_role
  end

  test "a governor role is a primary role and not a secondary one" do
    worldwide_organisation = create(:worldwide_organisation)

    assert_nil worldwide_organisation.primary_role

    governor_role = create(:governor_role, :occupied, worldwide_organisations: [worldwide_organisation])

    assert_equal governor_role, worldwide_organisation.primary_role
    assert_nil worldwide_organisation.secondary_role
  end

  test "a deputy head of mission is second in charge and not a primary one" do
    worldwide_organisation = create(:worldwide_organisation)

    assert_nil worldwide_organisation.secondary_role

    deputy_role = create(:deputy_head_of_mission_role, :occupied, worldwide_organisations: [worldwide_organisation])

    assert_equal deputy_role, worldwide_organisation.secondary_role
    assert_nil worldwide_organisation.primary_role
  end

  test "office_staff_roles returns worldwide office staff roles" do
    worldwide_organisation = create(:worldwide_organisation)

    assert_equal [], worldwide_organisation.office_staff_roles

    staff_role_1 = create(:worldwide_office_staff_role, :occupied, worldwide_organisations: [worldwide_organisation])
    staff_role_2 = create(:worldwide_office_staff_role, :occupied, worldwide_organisations: [worldwide_organisation])

    assert_equal [staff_role_1, staff_role_2], worldwide_organisation.office_staff_roles
    assert_nil worldwide_organisation.primary_role
    assert_nil worldwide_organisation.secondary_role
  end

  test "primary, secondary and office staff roles return occupied roles only" do
    org = create(:worldwide_organisation)

    create(:ambassador_role, :vacant, worldwide_organisations: [org])
    create(:deputy_head_of_mission_role, :vacant, worldwide_organisations: [org])
    create(:worldwide_office_staff_role, :vacant, worldwide_organisations: [org])

    assert_nil org.primary_role
    assert_nil org.secondary_role
    assert_equal [], org.office_staff_roles

    a = create(:ambassador_role, :occupied, worldwide_organisations: [org])
    b = create(:deputy_head_of_mission_role, :occupied, worldwide_organisations: [org])
    c = create(:worldwide_office_staff_role, :occupied, worldwide_organisations: [org])

    assert_equal a, org.primary_role
    assert_equal b, org.secondary_role
    assert_equal [c], org.office_staff_roles
  end

  test "has removeable translations" do
    stub_any_publishing_api_call

    worldwide_organisation = create(:worldwide_organisation, translated_into: %i[fr es])
    worldwide_organisation.remove_translations_for(:fr)
    assert_not worldwide_organisation.translated_locales.include?(:fr)
    assert worldwide_organisation.translated_locales.include?(:es)
  end

  test "can list unused corporate information types" do
    organisation = create(:worldwide_organisation)
    types = CorporateInformationPageType.all
    create(:corporate_information_page, corporate_information_page_type: types.pop, organisation: nil, worldwide_organisation: organisation)

    assert_equal types, organisation.reload.unused_corporate_information_page_types
  end

  test 'adds worldwide organisation to search index on creating' do
    worldwide_organisation = build(:worldwide_organisation)

    Whitehall::SearchIndex.expects(:add).with(worldwide_organisation)

    worldwide_organisation.save
  end

  test 'adds worldwide organisation to search index on updating' do
    worldwide_organisation = create(:worldwide_organisation)

    Whitehall::SearchIndex.expects(:add).with(worldwide_organisation)

    worldwide_organisation.name = 'British Embassy to Hat land'
    worldwide_organisation.save
  end

  test 'removes worldwide organisation role from search index on destroying if it is active' do
    worldwide_organisation = create(:worldwide_organisation)
    Whitehall::SearchIndex.expects(:delete).with(worldwide_organisation)
    worldwide_organisation.destroy
  end

  test 'search index data for a worldwide organisation includes name, summary, the correct link and format' do
    worldwide_organisation = create(:worldwide_organisation, content_id: '7d58b5d8-6d91-4dbb-b3e1-c2a27f131046', name: 'British Embassy to Hat land', slug: 'british-embassy-to-hat-land')
    create(:published_corporate_information_page, corporate_information_page_type: CorporateInformationPageType.find('about'), worldwide_organisation: worldwide_organisation, organisation: nil, summary: 'Providing assistance to uk residents in hat land')

    assert_equal({ 'title' => worldwide_organisation.name,
                  'content_id' => '7d58b5d8-6d91-4dbb-b3e1-c2a27f131046',
                  'link' => '/world/organisations/british-embassy-to-hat-land',
                  'indexable_content' => 'Providing assistance to uk residents in hat land',
                  'format' => 'worldwide_organisation',
                  'description' => 'Providing assistance to uk residents in hat land' }, worldwide_organisation.search_index)
  end

  test 'knows if a given office is on its home page' do
    world_organisation = build(:worldwide_organisation)
    office = build(:worldwide_office)
    h = build(:home_page_list)
    HomePageList.stubs(:get).returns(h)
    h.expects(:shown_on_home_page?).with(office).returns :the_answer

    assert_equal :the_answer, world_organisation.office_shown_on_home_page?(office)
  end

  test 'knows that the main office is on the home page, even if it\'s not explicitly in the list' do
    world_organisation = create(:worldwide_organisation)
    office_1 = create(:worldwide_office, worldwide_organisation: world_organisation)
    office_2 = create(:worldwide_office, worldwide_organisation: world_organisation)
    world_organisation.add_office_to_home_page!(office_1)
    world_organisation.main_office = office_2

    assert world_organisation.office_shown_on_home_page?(office_2)
  end

  test 'has a list of offices that are on its home page' do
    world_organisation = build(:worldwide_organisation)
    h = build(:home_page_list)
    HomePageList.stubs(:get).returns(h)
    h.expects(:items).returns [:the_list_of_offices]

    assert_equal [:the_list_of_offices], world_organisation.home_page_offices
  end

  test 'the list of offices that are on its home page excludes the main office' do
    world_organisation = create(:worldwide_organisation)
    office_1 = create(:worldwide_office, worldwide_organisation: world_organisation)
    office_2 = create(:worldwide_office, worldwide_organisation: world_organisation)
    office_3 = create(:worldwide_office, worldwide_organisation: world_organisation)
    world_organisation.add_office_to_home_page!(office_1)
    world_organisation.add_office_to_home_page!(office_2)
    world_organisation.add_office_to_home_page!(office_3)
    world_organisation.main_office = office_2

    assert_equal [office_1, office_3], world_organisation.home_page_offices
  end

  test 'can add a office to the list of those that are on its home page' do
    world_organisation = build(:worldwide_organisation)
    office = build(:worldwide_office)
    h = build(:home_page_list)
    HomePageList.stubs(:get).returns(h)
    h.expects(:add_item).with(office).returns :a_result

    assert_equal :a_result, world_organisation.add_office_to_home_page!(office)
  end

  test 'can remove a office from the list of those that are on its home page' do
    world_organisation = build(:worldwide_organisation)
    office = build(:worldwide_office)
    h = build(:home_page_list)
    HomePageList.stubs(:get).returns(h)
    h.expects(:remove_item).with(office).returns :a_result

    assert_equal :a_result, world_organisation.remove_office_from_home_page!(office)
  end

  test 'can reorder the contacts on the list' do
    world_organisation = build(:worldwide_organisation)
    office_1 = build(:worldwide_office)
    office_2 = build(:worldwide_office)
    h = build(:home_page_list)
    HomePageList.stubs(:get).returns(h)
    h.expects(:reorder_items!).with([office_1, office_2]).returns :a_result

    assert_equal :a_result, world_organisation.reorder_offices_on_home_page!([office_1, office_2])
  end

  test 'maintains a home page list for storing offices' do
    world_organisation = build(:worldwide_organisation)
    HomePageList.expects(:get).with(has_entries(owned_by: world_organisation, called: 'offices')).returns :a_home_page_list_of_offices
    assert_equal :a_home_page_list_of_offices, world_organisation.__send__(:home_page_offices_list)
  end

  test 'when destroyed, will remove its home page list for storing offices' do
    world_organisation = create(:worldwide_organisation)
    h = world_organisation.__send__(:home_page_offices_list)
    world_organisation.destroy
    assert_not HomePageList.exists?(h.id)
  end

  test "#save triggers organisation with a changed default news organisation image to republish news articles" do
    world_organisation = create(:worldwide_organisation)

    documents = NewsArticle
      .in_worldwide_organisation(world_organisation)
      .includes(:images)
      .where(images: { id: nil })
      .map(&:documents)

    documents.each do |d|
      Whitehall::PublishingApi.expects(:republish_document_async).with(d)
    end

    world_organisation.update_attribute(
      :default_news_image,
      create(:default_news_organisation_image_data),
    )
  end
end
