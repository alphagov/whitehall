require "test_helper"

class Admin::OrganisationsControllerTest < ActionController::TestCase
  setup do
    login_as :gds_admin
  end

  should_be_an_admin_controller

  def example_organisation_attributes
    attributes_for(:organisation).except(:logo, :analytics_identifier)
  end

  test "GET on :index assigns all organisations in alphabetical order" do
    org2 = create(:organisation, name: "org 2")
    org1 = create(:organisation, name: "org 1")
    get :index

    assert_response :success
    assert_template :index
    assert_equal [org1, org2], assigns(:organisations)
  end

  test "GET on :new denied if not a gds admin" do
    login_as :writer
    get :new
    assert_response :forbidden
  end

  test "POST on :create denied if not a gds admin" do
    login_as :writer
    post :create, params: { organisation: {} }
    assert_response :forbidden
  end

  view_test "Link to create organisation does not show if not a gds admin" do
    login_as :writer
    get :index
    refute_select ".btn", text: "Create organisation"
  end

  view_test "Link to create organisation shows if a gds admin" do
    get :index
    assert_select ".btn", text: "Create organisation"
  end

  test "POST on :create saves the organisation and its associations" do
    attributes = example_organisation_attributes

    parent_org_1 = create(:organisation)
    parent_org_2 = create(:organisation)
    topic_ids = [create(:topic), create(:topic)].map(&:id)

    post :create, params: {
organisation: attributes.merge(
      organisation_classifications_attributes: [
        { classification_id: topic_ids[0], ordering: 1 },
        { classification_id: topic_ids[1], ordering: 2 }
      ],
      parent_organisation_ids: [parent_org_1.id, parent_org_2.id],
      organisation_type_key: :executive_agency,
      govuk_status: 'exempt',
      featured_links_attributes: {
        "0" => {
          url: "http://www.gov.uk/mainstream/something",
          title: "Something on mainstream"
        }
      }
    )
}

    assert_redirected_to admin_organisations_path
    assert organisation = Organisation.last
    assert organisation.organisation_classifications.map(&:ordering).all?(&:present?), "no ordering"
    assert_equal organisation.organisation_classifications.map(&:ordering).sort, organisation.organisation_classifications.map(&:ordering).uniq.sort
    assert_equal topic_ids, organisation.organisation_classifications.sort_by(&:ordering).map(&:classification_id)
    assert organisation_top_task = organisation.featured_links.last
    assert_equal "http://www.gov.uk/mainstream/something", organisation_top_task.url
    assert_equal "Something on mainstream", organisation_top_task.title
    assert_same_elements [parent_org_1, parent_org_2], organisation.parent_organisations
    assert_equal OrganisationType.executive_agency, organisation.organisation_type
    assert_equal 'exempt', organisation.govuk_status
  end

  test 'POST :create can set a custom logo' do
    post :create, params: {
organisation: example_organisation_attributes.merge(
      organisation_logo_type_id: OrganisationLogoType::CustomLogo.id,
      logo: fixture_file_upload('logo.png', 'image/png')
    )
}
    assert_match /logo.png/, Organisation.last.logo.file.filename
  end

  test 'POST create can set number of important board members' do
    post :create, params: {
organisation: example_organisation_attributes.merge(
      important_board_members: 1,
    )
}
    assert_equal 1, Organisation.last.important_board_members
  end

  test "POST on :create with invalid data re-renders the new form" do
    attributes = example_organisation_attributes

    assert_no_difference('Organisation.count') do
      post :create, params: { organisation: attributes.merge(name: '') }
    end
    assert_response :success
    assert_template :new
  end

  test "GET on :show loads the organisation and renders the show template" do
    organisation = create(:organisation)
    get :show, params: { id: organisation }

    assert_response :success
    assert_template :show
  end

  test "GET on :edit loads the organisation and renders the edit template" do
    organisation = create(:organisation)
    get :edit, params: { id: organisation }

    assert_response :success
    assert_template :edit
    assert_equal organisation, assigns(:organisation)
  end

  view_test "GET on :people shows roles for ordering in separate lists" do
    ministerial_role = create(:ministerial_role)
    board_member_role = create(:board_member_role)
    chief_scientific_advisor_role = create(:chief_scientific_advisor_role)
    traffic_commissioner_role = create(:traffic_commissioner_role)
    chief_professional_officer_role = create(:chief_professional_officer_role)
    military_role = create(:military_role)

    organisation = create(:organisation)
    organisation_ministerial_role = create(:organisation_role, organisation: organisation, role: ministerial_role)
    organisation_board_member_role = create(:organisation_role, organisation: organisation, role: board_member_role)
    organisation_scientific_role = create(:organisation_role, organisation: organisation, role: chief_scientific_advisor_role)
    organisation_traffic_commissioner_role = create(:organisation_role, organisation: organisation, role: traffic_commissioner_role)
    organisation_chief_professional_officer_role = create(:organisation_role, organisation: organisation, role: chief_professional_officer_role)
    organisation_military_role = create(:organisation_role, organisation: organisation, role: military_role)

    get :people, params: { id: organisation }

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

  view_test "GET on :people shows ministerial role and current person's name" do
    person = create(:person, forename: "John", surname: "Doe")
    ministerial_role = create(:ministerial_role, name: "Prime Minister")
    create(:role_appointment, person: person, role: ministerial_role, started_at: 1.day.ago)
    organisation = create(:organisation, roles: [ministerial_role])

    get :people, params: { id: organisation }

    assert_select "#minister_ordering label", text: /Prime Minister/i
    assert_select "#minister_ordering label", text: /John Doe/i
  end

  test "GET on :people shows ministerial roles in their currently specified order" do
    junior_ministerial_role = create(:ministerial_role)
    senior_ministerial_role = create(:ministerial_role)
    organisation = create(:organisation)
    organisation_junior_ministerial_role = create(:organisation_role, organisation: organisation, role: junior_ministerial_role, ordering: 2)
    organisation_senior_ministerial_role = create(:organisation_role, organisation: organisation, role: senior_ministerial_role, ordering: 1)

    get :people, params: { id: organisation }

    assert_equal [organisation_senior_ministerial_role, organisation_junior_ministerial_role], assigns(:ministerial_organisation_roles)
  end

  test "GET on :people shows board member roles in their currently specified order" do
    junior_board_member_role = create(:board_member_role)
    senior_board_member_role = create(:board_member_role)
    chief_scientific_advisor_role = create(:chief_scientific_advisor_role)

    organisation = create(:organisation)
    organisation_chief_scientific_advisor_role = create(:organisation_role, organisation: organisation, role: chief_scientific_advisor_role, ordering: 2)
    organisation_junior_board_member_role = create(:organisation_role, organisation: organisation, role: junior_board_member_role, ordering: 3)
    organisation_senior_board_member_role = create(:organisation_role, organisation: organisation, role: senior_board_member_role, ordering: 1)

    get :people, params: { id: organisation }

    assert_equal [
      organisation_senior_board_member_role,
      organisation_chief_scientific_advisor_role,
      organisation_junior_board_member_role
    ], assigns(:management_organisation_roles)
  end

  test "GET on :people shows traffic commissioner roles in their currently specified order" do
    junior_traffic_commissioner_role = create(:traffic_commissioner_role)
    senior_traffic_commissioner_role = create(:traffic_commissioner_role)
    organisation = create(:organisation)
    organisation_junior_traffic_commissioner_role = create(:organisation_role, organisation: organisation, role: junior_traffic_commissioner_role, ordering: 2)
    organisation_senior_traffic_commissioner_role = create(:organisation_role, organisation: organisation, role: senior_traffic_commissioner_role, ordering: 1)

    get :people, params: { id: organisation }

    assert_equal [organisation_senior_traffic_commissioner_role, organisation_junior_traffic_commissioner_role], assigns(:traffic_commissioner_organisation_roles)
  end

  test "GET on :people shows chief professional officer roles in their currently specified order" do
    junior_chief_professional_officer_role = create(:chief_professional_officer_role)
    senior_chief_professional_officer_role = create(:chief_professional_officer_role)
    organisation = create(:organisation)
    organisation_junior_chief_professional_officer_role = create(:organisation_role, organisation: organisation, role: junior_chief_professional_officer_role, ordering: 2)
    organisation_senior_chief_professional_officer_role = create(:organisation_role, organisation: organisation, role: senior_chief_professional_officer_role, ordering: 1)

    get :people, params: { id: organisation }

    assert_equal [organisation_senior_chief_professional_officer_role, organisation_junior_chief_professional_officer_role], assigns(:chief_professional_officer_roles)
  end

  test "GET on :people shows special representative roles in their currently specified order" do
    junior_representative_role = create(:special_representative_role)
    senior_representative_role = create(:special_representative_role)
    organisation = create(:organisation)
    organisation_junior_representative_role = create(:organisation_role, organisation: organisation, role: junior_representative_role, ordering: 2)
    organisation_senior_representative_role = create(:organisation_role, organisation: organisation, role: senior_representative_role, ordering: 1)

    get :people, params: { id: organisation }

    assert_equal [organisation_senior_representative_role, organisation_junior_representative_role], assigns(:special_representative_organisation_roles)
  end

  view_test "GET on :people does not display an empty ministerial roles section" do
    organisation = create(:organisation)
    get :people, params: { id: organisation }
    refute_select "#minister_ordering"
  end

  view_test "GET on :people contains the relevant dom classes to facilitate the javascript ordering functionality" do
    organisation = create(:organisation, roles: [create(:ministerial_role)])
    get :people, params: { id: organisation }
    assert_select "fieldset#minister_ordering.sortable input.ordering[name^='organisation[organisation_roles_attributes]']"
  end

  view_test "GET on :edit allows entry of important board members only data to gds editors" do
    organisation = create(:organisation)
    user = create(:gds_editor, organisation: organisation)
    junior_board_member_role = create(:board_member_role)
    senior_board_member_role = create(:board_member_role)

    organisation = create(:organisation)
    organisation_senior_board_member_role = create(:organisation_role, organisation: organisation, role: senior_board_member_role)
    organisation_junior_board_member_role = create(:organisation_role, organisation: organisation, role: junior_board_member_role)

    get :edit, params: { id: organisation }

    assert_select 'select#organisation_important_board_members option', count: 2
  end

  test "PUT on :update allows updating of organisation role ordering" do
    organisation = create(:organisation)
    ministerial_role = create(:ministerial_role)
    organisation_role = create(:organisation_role, organisation: organisation, role: ministerial_role, ordering: 1)

    put :update, params: { id: organisation.id, organisation: { organisation_roles_attributes: {
      "0" => {id: organisation_role.id, ordering: "2"}
    } } }

    assert_equal 2, organisation_role.reload.ordering
  end

  test 'PUT :update can set a custom logo' do
    organisation = create(:organisation)
    put :update, params: { id: organisation, organisation: {
      organisation_logo_type_id: OrganisationLogoType::CustomLogo.id,
      logo: fixture_file_upload('logo.png')
    } }
    assert_match /logo.png/, organisation.reload.logo.file.filename
  end

  test 'PUT :update can set default news image' do
    organisation = create(:organisation)
    put :update, params: { id: organisation, organisation: {
      default_news_image_attributes: {
        file: fixture_file_upload('minister-of-funk.960x640.jpg')
      }
    } }
    assert_equal 'minister-of-funk.960x640.jpg', organisation.reload.default_news_image.file.file.filename
  end

  test "PUT on :update with bad params does not update the organisation and renders the edit page" do
    ministerial_role = create(:ministerial_role)
    organisation = create(:organisation, name: 'org name')
    create(:organisation_role, organisation: organisation, role: ministerial_role)

    put :update, params: { id: organisation, organisation: { name: "" } }

    assert_response :success
    assert_template :edit

    assert_equal 'org name', organisation.reload.name
  end

  test "PUT on :update should modify the organisation" do
    organisation = create(:organisation, name: "Ministry of Sound")
    organisation_attributes = {
      name: "Ministry of Noise",
    }

    put :update, params: { id: organisation, organisation: organisation_attributes }

    organisation.reload
    assert_equal "Ministry of Noise", organisation.name
  end

  test "PUT on :update handles non-departmental public body information" do
    organisation = create(:organisation)

    put :update, params: { id: organisation, organisation: {
      ocpa_regulated: 'false',
      public_meetings: 'true',
      public_minutes: 'true',
      regulatory_function: 'false'
    } }

    organisation.reload

    assert_response :redirect
    refute organisation.ocpa_regulated?
    assert organisation.public_meetings?
    assert organisation.public_minutes?
    refute organisation.regulatory_function?
  end

  test 'PUT on :update handles existing featured link attributes' do
    organisation = create(:organisation)
    featured_link = create(:featured_link, linkable: organisation)

    put :update, params: { id: organisation, organisation: { featured_links_attributes: { '0' => {
      id: featured_link.id,
      title: 'New title',
      url: featured_link.url,
      _destroy: 'false'
    } } } }

    assert_response :redirect
    assert_equal 'New title', featured_link.reload.title
  end

  view_test "Prevents unauthorized management of homepage priority" do
    organisation = create(:organisation)
    writer = create(:writer, organisation: organisation)
    login_as(writer)

    get :edit, params: { id: organisation }
    refute_select ".homepage-priority"

    managing_editor = create(:managing_editor, organisation: organisation)
    login_as(managing_editor)
    get :edit, params: { id: organisation }
    assert_select ".homepage-priority"

    gds_editor = create(:gds_editor, organisation: organisation)
    login_as(gds_editor)
    get :edit, params: { id: organisation }
    assert_select ".homepage-priority"
  end

  test "Non-admins can only edit their own organisations or children" do
    organisation = create(:organisation)
    gds_editor = create(:gds_editor, organisation: organisation)
    login_as(gds_editor)

    get :edit, params: { id: organisation }
    assert_response :success

    organisation2 = create(:organisation)
    get :edit, params: { id: organisation2 }
    assert_response 403

    organisation2.parent_organisations << organisation
    get :edit, params: { id: organisation2 }
    assert_response :success
  end

  view_test "GET :features copes with topical events that have no dates" do
    topical_event = create(:topical_event)
    organisation = create(:organisation)
    feature_list = organisation.load_or_create_feature_list('en')
    feature_list.features.create!(topical_event: topical_event,
                                  image: image_fixture_file,
                                  alt_text: 'Image alternative text')


    get :features, params: { id: organisation, locale: 'en' }
    assert_response :success
  end

  view_test "GET :features without an organisation defaults to the user organisation" do
    organisation = create(:organisation)

    get :features, params: { id: organisation, locale: 'en' }
    assert_response :success

    selected_organisation = css_select('#organisation option[selected="selected"]')
    assert_equal selected_organisation.text, organisation.name
  end

  view_test "GDS Editors can set political status" do
    organisation = create(:organisation)
    writer = create(:writer, organisation: organisation)
    login_as(writer)

    get :edit, params: { id: organisation }
    refute_select ".political-status"

    managing_editor = create(:managing_editor, organisation: organisation)
    login_as(managing_editor)
    get :edit, params: { id: organisation }
    refute_select ".political-status"

    gds_editor = create(:gds_editor, organisation: organisation)
    login_as(gds_editor)
    get :edit, params: { id: organisation }
    assert_select ".political-status"
  end
end
