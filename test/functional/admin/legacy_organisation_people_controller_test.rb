require "test_helper"

class Admin::LegacyOrganisationPeopleControllerTest < ActionController::TestCase
  tests Admin::OrganisationPeopleController
  setup do
    login_as :gds_admin
  end

  should_be_an_admin_controller

  test "GET :reorder access denied if not a gds admin" do
    organisation = create(:organisation)
    login_as_preview_design_system_user :writer
    get :reorder, params: {
      type: "ministerial",
      organisation_id: organisation,
    }
    assert_response :forbidden
  end

  test "PUT :order access denied if not a gds admin" do
    organisation = create(:organisation)
    organisation_role = create(:organisation_role, organisation:)
    login_as_preview_design_system_user :writer
    put :order, params: {
      type: "ministerial",
      organisation_id: organisation,
      ordering: {
        organisation_role.id.to_s => "1",
      },
    }
    assert_response :forbidden
  end

  view_test "GET on :index shows roles for ordering in separate lists" do
    ministerial_role = create(:ministerial_role)
    board_member_role = create(:board_member_role)
    chief_scientific_advisor_role = create(:chief_scientific_advisor_role)
    traffic_commissioner_role = create(:traffic_commissioner_role)
    chief_professional_officer_role = create(:chief_professional_officer_role)
    military_role = create(:military_role)

    organisation = create(:organisation)
    organisation_ministerial_role = create(:organisation_role, organisation:, role: ministerial_role)
    organisation_board_member_role = create(:organisation_role, organisation:, role: board_member_role)
    organisation_scientific_role = create(:organisation_role, organisation:, role: chief_scientific_advisor_role)
    organisation_traffic_commissioner_role = create(:organisation_role, organisation:, role: traffic_commissioner_role)
    organisation_chief_professional_officer_role = create(:organisation_role, organisation:, role: chief_professional_officer_role)
    organisation_military_role = create(:organisation_role, organisation:, role: military_role)

    get :index, params: { organisation_id: organisation }

    assert_select "#minister_ordering input[type='hidden'][name^='organisation[organisation_roles_attributes]'][value='#{organisation_ministerial_role.id}']"
    refute_select "#minister_ordering input[type='hidden'][name^='organisation[organisation_roles_attributes]'][value='#{organisation_board_member_role.id}']"
    refute_select "#minister_ordering input[type='hidden'][name^='organisation[organisation_roles_attributes]'][value='#{organisation_traffic_commissioner_role.id}']"
    refute_select "#minister_ordering input[type='hidden'][name^='organisation[organisation_roles_attributes]'][value='#{organisation_scientific_role.id}']"

    assert_select "#board_member_ordering input[type='hidden'][name^='organisation[organisation_roles_attributes]'][value='#{organisation_board_member_role.id}']"
    assert_select "#board_member_ordering input[type='hidden'][name^='organisation[organisation_roles_attributes]'][value='#{organisation_scientific_role.id}']"
    refute_select "#board_member_ordering input[type='hidden'][name^='organisation[organisation_roles_attributes]'][value='#{organisation_ministerial_role.id}']"
    refute_select "#board_member_ordering input[type='hidden'][name^='organisation[organisation_roles_attributes]'][value='#{organisation_traffic_commissioner_role.id}']"

    assert_select "#traffic_commissioner_ordering input[type='hidden'][name^='organisation[organisation_roles_attributes]'][value='#{organisation_traffic_commissioner_role.id}']"
    refute_select "#traffic_commissioner_ordering input[type='hidden'][name^='organisation[organisation_roles_attributes]'][value='#{organisation_ministerial_role.id}']"
    refute_select "#traffic_commissioner_ordering input[type='hidden'][name^='organisation[organisation_roles_attributes]'][value='#{organisation_board_member_role.id}']"
    refute_select "#traffic_commissioner_ordering input[type='hidden'][name^='organisation[organisation_roles_attributes]'][value='#{organisation_scientific_role.id}']"

    assert_select "#military_ordering input[type='hidden'][name^='organisation[organisation_roles_attributes]'][value='#{organisation_military_role.id}']"
    refute_select "#military_ordering input[type='hidden'][name^='organisation[organisation_roles_attributes]'][value='#{organisation_ministerial_role.id}']"
    refute_select "#military_ordering input[type='hidden'][name^='organisation[organisation_roles_attributes]'][value='#{organisation_board_member_role.id}']"
    refute_select "#military_ordering input[type='hidden'][name^='organisation[organisation_roles_attributes]'][value='#{organisation_traffic_commissioner_role.id}']"
    refute_select "#military_ordering input[type='hidden'][name^='organisation[organisation_roles_attributes]'][value='#{organisation_scientific_role.id}']"

    assert_select "#chief_professional_officer_ordering input[type='hidden'][name^='organisation[organisation_roles_attributes]'][value='#{organisation_chief_professional_officer_role.id}']"
    refute_select "#chief_professional_officer_ordering input[type='hidden'][name^='organisation[organisation_roles_attributes]'][value='#{organisation_ministerial_role.id}']"
    refute_select "#chief_professional_officer_ordering input[type='hidden'][name^='organisation[organisation_roles_attributes]'][value='#{organisation_board_member_role.id}']"
    refute_select "#chief_professional_officer_ordering input[type='hidden'][name^='organisation[organisation_roles_attributes]'][value='#{organisation_traffic_commissioner_role.id}']"
    refute_select "#chief_professional_officer_ordering input[type='hidden'][name^='organisation[organisation_roles_attributes]'][value='#{organisation_scientific_role.id}']"
  end

  view_test "GET on :index shows ministerial role and current person's name" do
    person = create(:person, forename: "John", surname: "Doe")
    ministerial_role = create(:ministerial_role, name: "Prime Minister")
    create(:role_appointment, person:, role: ministerial_role, started_at: 1.day.ago)
    organisation = create(:organisation, roles: [ministerial_role])

    get :index, params: { organisation_id: organisation }

    assert_select "#minister_ordering label", text: /Prime Minister/i
    assert_select "#minister_ordering label", text: /John Doe/i
  end

  test "GET on :index shows ministerial roles in their currently specified order" do
    junior_ministerial_role = create(:ministerial_role)
    senior_ministerial_role = create(:ministerial_role)
    organisation = create(:organisation)
    organisation_junior_ministerial_role = create(:organisation_role, organisation:, role: junior_ministerial_role, ordering: 2)
    organisation_senior_ministerial_role = create(:organisation_role, organisation:, role: senior_ministerial_role, ordering: 1)

    get :index, params: { organisation_id: organisation }

    assert_equal [organisation_senior_ministerial_role, organisation_junior_ministerial_role], assigns(:ministerial_organisation_roles)
  end

  test "GET on :index shows board member roles in their currently specified order" do
    junior_board_member_role = create(:board_member_role)
    senior_board_member_role = create(:board_member_role)
    chief_scientific_advisor_role = create(:chief_scientific_advisor_role)

    organisation = create(:organisation)
    organisation_chief_scientific_advisor_role = create(:organisation_role, organisation:, role: chief_scientific_advisor_role, ordering: 2)
    organisation_junior_board_member_role = create(:organisation_role, organisation:, role: junior_board_member_role, ordering: 3)
    organisation_senior_board_member_role = create(:organisation_role, organisation:, role: senior_board_member_role, ordering: 1)

    get :index, params: { organisation_id: organisation }

    assert_equal [
      organisation_senior_board_member_role,
      organisation_chief_scientific_advisor_role,
      organisation_junior_board_member_role,
    ],
                 assigns(:management_organisation_roles)
  end

  test "GET on :index shows traffic commissioner roles in their currently specified order" do
    junior_traffic_commissioner_role = create(:traffic_commissioner_role)
    senior_traffic_commissioner_role = create(:traffic_commissioner_role)
    organisation = create(:organisation)
    organisation_junior_traffic_commissioner_role = create(:organisation_role, organisation:, role: junior_traffic_commissioner_role, ordering: 2)
    organisation_senior_traffic_commissioner_role = create(:organisation_role, organisation:, role: senior_traffic_commissioner_role, ordering: 1)

    get :index, params: { organisation_id: organisation }

    assert_equal [organisation_senior_traffic_commissioner_role, organisation_junior_traffic_commissioner_role], assigns(:traffic_commissioner_organisation_roles)
  end

  test "GET on :index shows chief professional officer roles in their currently specified order" do
    junior_chief_professional_officer_role = create(:chief_professional_officer_role)
    senior_chief_professional_officer_role = create(:chief_professional_officer_role)
    organisation = create(:organisation)
    organisation_junior_chief_professional_officer_role = create(:organisation_role, organisation:, role: junior_chief_professional_officer_role, ordering: 2)
    organisation_senior_chief_professional_officer_role = create(:organisation_role, organisation:, role: senior_chief_professional_officer_role, ordering: 1)

    get :index, params: { organisation_id: organisation }

    assert_equal [organisation_senior_chief_professional_officer_role, organisation_junior_chief_professional_officer_role], assigns(:chief_professional_officer_roles)
  end

  test "GET on :index shows special representative roles in their currently specified order" do
    junior_representative_role = create(:special_representative_role)
    senior_representative_role = create(:special_representative_role)
    organisation = create(:organisation)
    organisation_junior_representative_role = create(:organisation_role, organisation:, role: junior_representative_role, ordering: 2)
    organisation_senior_representative_role = create(:organisation_role, organisation:, role: senior_representative_role, ordering: 1)

    get :index, params: { organisation_id: organisation }

    assert_equal [organisation_senior_representative_role, organisation_junior_representative_role], assigns(:special_representative_organisation_roles)
  end

  view_test "GET on :index does not display an empty ministerial roles section" do
    organisation = create(:organisation)
    get :index, params: { organisation_id: organisation }
    refute_select "#minister_ordering"
  end

  test "GET on :reorder renders a reorderable table of ministerial roles" do
    junior_ministerial_role = create(:ministerial_role)
    senior_ministerial_role = create(:ministerial_role)
    organisation = create(:organisation)
    organisation_junior_ministerial_role = create(:organisation_role, organisation:, role: junior_ministerial_role, ordering: 2)
    organisation_senior_ministerial_role = create(:organisation_role, organisation:, role: senior_ministerial_role, ordering: 1)

    get :reorder, params: { organisation_id: organisation, type: "ministerial" }

    assert_equal [organisation_senior_ministerial_role, organisation_junior_ministerial_role], assigns(:organisation_roles)
  end

  test "GET on :reorder renders a reorderable table of special representative roles only" do
    junior_ministerial_role = create(:ministerial_role)
    senior_ministerial_role = create(:ministerial_role)
    junior_representative_role = create(:special_representative_role)
    senior_representative_role = create(:special_representative_role)
    organisation = create(:organisation)
    organisation_junior_representative_role = create(:organisation_role, organisation:, role: junior_representative_role, ordering: 2)
    organisation_senior_representative_role = create(:organisation_role, organisation:, role: senior_representative_role, ordering: 1)
    create(:organisation_role, organisation:, role: junior_ministerial_role, ordering: 2)
    create(:organisation_role, organisation:, role: senior_ministerial_role, ordering: 1)
    get :reorder, params: { organisation_id: organisation, type: "special_representative" }

    assert_equal [organisation_senior_representative_role, organisation_junior_representative_role], assigns(:organisation_roles)
  end

  test "PUT on :order reorders and saves the order of people" do
    organisation = create(:organisation)

    organisation_senior_ministerial_role = create(:organisation_role, organisation:)
    organisation_junior_ministerial_role = create(:organisation_role, organisation:)

    put :order,
        params: {
          organisation_id: organisation,
          ordering: {
            organisation_junior_ministerial_role.id.to_s => "1",
            organisation_senior_ministerial_role.id.to_s => "2",
          },
          type: "ministerial",
        }

    assert_response :redirect
    assert_equal 2, organisation.reload.organisation_roles.first.ordering
    assert_equal 1, organisation.reload.organisation_roles.second.ordering
  end
end
