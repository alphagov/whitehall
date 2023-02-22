require "test_helper"
require "gds_api/test_helpers/search"

class MinisterialRolesControllerTest < ActionController::TestCase
  include GdsApi::TestHelpers::Search

  should_be_a_public_facing_controller

  setup do
    stub_any_search_to_return_no_results
  end

  test "shows cabinet roles in correct order" do
    nick_clegg = create(:person, forename: "Nick", surname: "Clegg")
    jeremy_hunt = create(:person, forename: "Jeremy", surname: "Hunt")
    edward_garnier = create(:person, forename: "Edward", surname: "Garnier")
    david_cameron = create(:person, forename: "David", surname: "Cameron")
    philip_hammond = create(:person, forename: "Philip", surname: "Hammond")
    davey_jones = create(:person, forename: "Davey", surname: "Jones")

    deputy_prime_minister = create(:ministerial_role, name: "Deputy Prime Minister", cabinet_member: true, seniority: 1)
    culture_minister = create(:ministerial_role, name: "Secretary of State for Culture", cabinet_member: true)
    solicitor_general = create(:ministerial_role, name: "Solicitor General", cabinet_member: false)
    prime_minister = create(:ministerial_role, name: "Prime Minister", cabinet_member: true, seniority: 0)
    defence_minister = create(:ministerial_role, name: "Secretary of State for Defence", cabinet_member: true)
    first_sec_of_state = create(:ministerial_role, name: "First Secretary of State", cabinet_member: true, seniority: 2)

    create(:ministerial_role_appointment, role: deputy_prime_minister, person: nick_clegg)
    create(:ministerial_role_appointment, role: culture_minister, person: jeremy_hunt)
    create(:ministerial_role_appointment, role: solicitor_general, person: edward_garnier)
    create(:ministerial_role_appointment, role: prime_minister, person: david_cameron)
    create(:ministerial_role_appointment, role: defence_minister, person: philip_hammond)
    create(:ministerial_role_appointment, role: first_sec_of_state, person: davey_jones)

    get :index

    actual_roles = assigns(:cabinet_ministerial_roles).map { |_person, role| role.first.model }

    assert_equal [prime_minister, deputy_prime_minister, first_sec_of_state, defence_minister, culture_minister], actual_roles
  end

  test "shows ministers by organisation with the organisations in the cms-defined order" do
    organisation1 = create(:ministerial_department, ministerial_ordering: 1)
    organisation2 = create(:ministerial_department, ministerial_ordering: 0)

    create(
      :ministerial_role_appointment,
      person: create(:person),
      role: create(:ministerial_role, cabinet_member: true, organisations: [organisation1], seniority: 0),
    )

    create(
      :ministerial_role_appointment,
      person: create(:person),
      role: create(:ministerial_role, cabinet_member: true, organisations: [organisation2], seniority: 0),
    )

    get :index

    assert_equal [organisation2, organisation1], assigns(:ministers_by_organisation).map(&:first)
  end

  test "shows ministers by organisation with the ministers in the cms-defined order" do
    organisation = create(:ministerial_department)

    person1 = create(:person, forename: "Nick", surname: "Clegg")
    person2 = create(:person, forename: "Jeremy", surname: "Hunt")
    person3 = create(:person, forename: "George", surname: "Foreman")
    person4 = create(:person, forename: "Brian", surname: "Smith")

    role1 = create(:ministerial_role, name: "Prime Minister", cabinet_member: true, organisations: [organisation], seniority: 0)
    role2 = create(:ministerial_role, name: "Non-Executive Director", cabinet_member: false, organisations: [organisation], seniority: 1)
    role3 = create(:board_member_role, name: "Chief Griller", organisations: [organisation], seniority: 3)
    role4 = create(:ministerial_role, name: "First Secretary of State", cabinet_member: true, organisations: [organisation], seniority: 2)

    organisation.organisation_roles.find_by(role_id: role2.id).update_column(:ordering, 3)
    organisation.organisation_roles.find_by(role_id: role1.id).update_column(:ordering, 2)
    organisation.organisation_roles.find_by(role_id: role4.id).update_column(:ordering, 1)

    create(:board_member_role_appointment, role: role3, person: person3)
    create(:ministerial_role_appointment, role: role1, person: person1)
    create(:ministerial_role_appointment, role: role2, person: person2)
    create(:ministerial_role_appointment, role: role4, person: person4)

    get :index

    expected_results = [[organisation, RolesPresenter.new([role4, role1, role2], @controller.view_context)]]
    assert_equal expected_results, assigns(:ministers_by_organisation)
  end

  test "doesn't list closed organisations in the ministers by organisation list" do
    organisation1 = create(:ministerial_department)
    person1 = create(:person, forename: "Tony", surname: "Blair")
    role1 = create(:ministerial_role, name: "Prime Minister", cabinet_member: true, organisations: [organisation1], seniority: 0)
    create(:ministerial_role_appointment, role: role1, person: person1)

    organisation2 = create(:ministerial_department, :closed)
    person2 = create(:person, forename: "Frank", surname: "Underwood")
    role2 = create(:ministerial_role, name: "President", cabinet_member: true, organisations: [organisation2], seniority: 0)
    create(:ministerial_role_appointment, role: role2, person: person2)

    get :index

    expected_results = [[organisation1, RolesPresenter.new([role1], @controller.view_context)]]
    assert_equal expected_results, assigns(:ministers_by_organisation)
  end

  test "shows ministers who also attend cabinet separately" do
    organisation = create(:ministerial_department)
    person1 = create(:person, forename: "Nick", surname: "Clegg")
    person2 = create(:person, forename: "Jeremy", surname: "Hunt")
    person3 = create(:person, forename: "Geroge", surname: "Foreman")

    role1 = create(:ministerial_role, name: "Prime Minister", cabinet_member: true, organisations: [organisation])
    role2 = create(:ministerial_role, name: "Non-Executive Director", cabinet_member: false, organisations: [organisation])
    role3 = create(:ministerial_role, name: "Chief Whip and Parliamentary Secretary to the Treasury", organisations: [organisation], whip_organisation_id: 1, attends_cabinet_type_id: 1)

    create(:ministerial_role_appointment, role: role1, person: person1)
    create(:ministerial_role_appointment, role: role2, person: person2)
    create(:ministerial_role_appointment, role: role3, person: person3)

    get :index

    actual_roles = assigns(:also_attends_cabinet).map { |_person, role| role.first.model }

    assert_equal [role3], actual_roles
  end

  test "shows whips separately" do
    organisation = create(:ministerial_department)
    person1 = create(:person, forename: "Nick", surname: "Clegg")
    person2 = create(:person, forename: "Jeremy", surname: "Hunt")
    person3 = create(:person, forename: "Geroge", surname: "Foreman")

    role1 = create(:ministerial_role, name: "Prime Minister", cabinet_member: true, organisations: [organisation])
    role2 = create(:ministerial_role, name: "Non-Executive Director", cabinet_member: false, organisations: [organisation])
    role3 = create(:ministerial_role, name: "Chief Whip and Parliamentary Secretary to the Treasury", organisations: [organisation], whip_organisation_id: 1)

    create(:ministerial_role_appointment, role: role1, person: person1)
    create(:ministerial_role_appointment, role: role2, person: person2)
    create(:ministerial_role_appointment, role: role3, person: person3)

    get :index

    whips = [[Whitehall::WhipOrganisation.find_by_id(1), RolesPresenter.new([role3], @controller.view_context)]]

    assert_equal whips, assigns(:whips_by_organisation)
  end

  test "orders whips by organisation sort order" do
    organisation = create(:ministerial_department)

    person1 = create(:person)
    person2 = create(:person)
    person3 = create(:person)
    person4 = create(:person)
    person5 = create(:person)

    role1 = create(:ministerial_role, organisations: [organisation], whip_organisation_id: 1)
    role2 = create(:ministerial_role, organisations: [organisation], whip_organisation_id: 2)
    role3 = create(:ministerial_role, organisations: [organisation], whip_organisation_id: 3)
    role4 = create(:ministerial_role, organisations: [organisation], whip_organisation_id: 4)
    role5 = create(:ministerial_role, organisations: [organisation], whip_organisation_id: 5)

    create(:ministerial_role_appointment, role: role1, person: person1)
    create(:ministerial_role_appointment, role: role2, person: person2)
    create(:ministerial_role_appointment, role: role3, person: person3)
    create(:ministerial_role_appointment, role: role4, person: person4)
    create(:ministerial_role_appointment, role: role5, person: person5)

    get :index

    whips = [
      [Whitehall::WhipOrganisation.find_by_id(1), RolesPresenter.new([role1], @controller.view_context)],
      [Whitehall::WhipOrganisation.find_by_id(3), RolesPresenter.new([role3], @controller.view_context)],
      [Whitehall::WhipOrganisation.find_by_id(4), RolesPresenter.new([role4], @controller.view_context)],
      [Whitehall::WhipOrganisation.find_by_id(2), RolesPresenter.new([role2], @controller.view_context)],
      [Whitehall::WhipOrganisation.find_by_id(5), RolesPresenter.new([role5], @controller.view_context)],
    ]
    assert_equal whips, assigns(:whips_by_organisation)
  end

  view_test "shows the cabinet minister's name and role" do
    person = create(:person, forename: "John", surname: "Doe", image: image_fixture_file)
    ministerial_role = create(:ministerial_role, name: "Prime Minister", cabinet_member: true)
    create(:role_appointment, person:, role: ministerial_role)

    get :index

    assert_select_object(person) do
      assert_select ".current-appointee", text: "John Doe"
      assert_minister_role_links_to_their_role(ministerial_role)
    end
  end

  view_test "shows the non-cabinet minister's name and role" do
    org = create(:ministerial_department)
    person = create(:person, forename: "John", surname: "Doe")
    ministerial_role = create(:ministerial_role, name: "Prime Minister", cabinet_member: false, organisations: [org])
    create(:role_appointment, person:, role: ministerial_role)

    get :index

    assert_select_prefix_object(person, "by-organisation-#{org.slug}") do
      assert_select "a[href=?]", person.public_path(locale: :en), text: "John Doe"
      assert_minister_role_links_to_their_role(ministerial_role)
    end
  end

  test "shows only latest role appointments" do
    person = create(:person, forename: "John", surname: "Doe")
    organisation = create(:ministerial_department)
    ministerial_role = create(:ministerial_role, name: "Prime Minister", cabinet_member: true, organisations: [organisation])
    old_role = create(:ministerial_role, name: "Pharoah", cabinet_member: true, organisations: [organisation])
    create(:role_appointment, person:, role: ministerial_role)
    create(:role_appointment, person:, role: old_role, started_at: 10.days.ago, ended_at: 5.days.ago)

    get :index

    expected_results = [[organisation, RolesPresenter.new([ministerial_role], @controller.view_context)]]
    assert_equal expected_results, assigns(:ministers_by_organisation)
  end

private

  def assert_minister_role_links_to_their_role(role)
    assert_select ".app-person__roles a[href='#{role.public_path(locale: :en)}']", text: role.name
  end
end
