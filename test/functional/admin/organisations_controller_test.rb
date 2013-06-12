require "test_helper"

class Admin::OrganisationsControllerTest < ActionController::TestCase
  setup do
    login_as :policy_writer
  end

  should_be_an_admin_controller

  test "index should list all the organisations in alphabetical order" do
    org2 = create(:organisation, name: "org 2")
    org1 = create(:organisation, name: "org 1")
    organisations = [org1, org2]
    get :index
    assert_equal organisations, assigns(:organisations)
  end

  view_test "should allow entry of new organisation data" do
    get :new
    assert_template "organisations/new"
    assert_select "input[type=text][name='organisation[alternative_format_contact_email]']"
    assert_select "textarea[name='organisation[description]']"
    assert_select "textarea[name='organisation[about_us]'].previewable"
    assert_select "#govspeak_help"
    assert_select parent_organisations_list_selector
    assert_select organisation_type_list_selector
    assert_select organisation_topics_list_selector
    assert_select organisation_govuk_status_selector
    assert_select "select[name='organisation[organisation_logo_type_id]']"
  end

  view_test "should display fields for new organisation mainstream links" do
    get :new

    assert_select "input[type=text][name='organisation[mainstream_links_attributes][0][url]']"
    assert_select "input[type=text][name='organisation[mainstream_links_attributes][0][title]']"
  end

  test "should allow creation of an organisation without any contact details" do
    organisation_type = create(:organisation_type)

    post :create, organisation: {
      name: "Anything",
      logo_formatted_name: "Anything",
      organisation_type_id: organisation_type.id
    }

    organisation = Organisation.last
    assert_kind_of Organisation, organisation
    assert_equal "Anything", organisation.name
  end

  test "creating correctly set ordering of topics" do
    attributes = attributes_for(:organisation)

    organisation_type = create(:organisation_type)
    topic_ids = [create(:topic), create(:topic)].map(&:id)

    post :create, organisation: attributes.merge(
      organisation_classifications_attributes: [
        {classification_id: topic_ids[0], ordering: 1 },
        {classification_id: topic_ids[1], ordering: 2 }
      ],
      organisation_type_id: organisation_type.id
    )

    assert organisation = Organisation.last
    assert organisation.organisation_classifications.map(&:ordering).all?(&:present?), "no ordering"
    assert_equal organisation.organisation_classifications.map(&:ordering).sort, organisation.organisation_classifications.map(&:ordering).uniq.sort
    assert_equal topic_ids, organisation.organisation_classifications.sort_by(&:ordering).map(&:classification_id)
  end

  test "creating will associate the org to a list of mainstream categories" do
    attributes = attributes_for(:organisation)

    organisation_type = create(:organisation_type)
    mainstream_category_ids = [create(:mainstream_category), create(:mainstream_category)].map(&:id)

    post :create, organisation: attributes.merge(
      organisation_mainstream_categories_attributes: [
        {mainstream_category_id: mainstream_category_ids[0], ordering: 2 },
        {mainstream_category_id: mainstream_category_ids[1], ordering: 1 }
      ],
      organisation_type_id: organisation_type.id
    )

    puts assigns(:organisation).errors.full_messages

    assert organisation = Organisation.last
    assert organisation.organisation_mainstream_categories.map(&:ordering).all?(&:present?), "no ordering"
    assert_equal [mainstream_category_ids[1], mainstream_category_ids[0]], organisation.organisation_mainstream_categories.sort_by(&:ordering).map(&:mainstream_category_id)
  end

  test "creating should be able to create a new mainstream link for the organisation" do
    attributes = attributes_for(:organisation)
    organisation_type = create(:organisation_type)

    post :create, organisation: attributes.merge(
      organisation_type_id: organisation_type.id,
      mainstream_links_attributes: {"0" =>{
        url: "http://www.gov.uk/mainstream/something",
        title: "Something on mainstream"
      }}
    )

    assert organisation = Organisation.last
    assert organisation_mainstream_link = organisation.mainstream_links.last
    assert_equal "http://www.gov.uk/mainstream/something", organisation_mainstream_link.url
    assert_equal "Something on mainstream", organisation_mainstream_link.title
  end

  test "updating should destroy existing mainstream links if all its field are blank" do
    attributes = attributes_for(:organisation)
    organisation = create(:organisation, attributes)
    link = create(:organisation_mainstream_link, organisation: organisation)

    put :update, id: organisation, organisation: attributes.merge(
      mainstream_links_attributes: {"0" =>{
          id: link.mainstream_link.id,
          url: "",
          title: ""
      }}
    )

    assert_equal 0, organisation.mainstream_links.length
  end

  test "creating should redirect back to the index" do
    organisation_type = create(:organisation_type)
    attributes = attributes_for(:organisation)
    post :create, organisation: attributes.merge(
      organisation_type_id: organisation_type.id
    )

    assert_redirected_to admin_organisations_path
  end

  test "creating with invalid data should reshow the edit form" do
    attributes = attributes_for(:organisation)
    post :create, organisation: attributes.merge(name: '')

    assert_template "organisations/new"
  end

  test "creating with multiple parent organisations" do
    organisation_type = create(:organisation_type)
    parent_org_1 = create(:organisation)
    parent_org_2 = create(:organisation)
    attributes = attributes_for(:organisation)
    post :create, organisation: attributes.merge(
      name: "new-organisation",
      organisation_type_id: organisation_type.id,
      parent_organisation_ids: [parent_org_1.id, parent_org_2.id]
    )
    created_organisation = Organisation.find_by_name("new-organisation")
    assert_same_elements [parent_org_1, parent_org_2], created_organisation.parent_organisations
  end

  test "creating with an organisation type" do
    organisation_type = create(:organisation_type)
    attributes = attributes_for(:organisation)
    post :create, organisation: attributes.merge(
      organisation_type_id: organisation_type.id
    )
    created_organisation = Organisation.last
    assert_equal organisation_type, created_organisation.organisation_type
  end

  test "creating with a govuk status" do
    attributes = attributes_for(:organisation)
    post :create, organisation: attributes.merge(
      govuk_status: 'exempt',
      organisation_type_id: create(:organisation_type).id
    )
    assert_equal 'exempt', Organisation.last.govuk_status
  end

  test "showing should load the requested organisation" do
    organisation = create(:organisation)
    get :show, id: organisation
    assert_equal organisation, assigns(:organisation)
  end

  view_test "showing displays the govuk status" do
    organisation = create(:organisation, govuk_status: 'exempt')
    get :show, id: organisation
    assert_select 'td', text: 'Exempt'
  end

  test "editing should load the requested organisation" do
    organisation = create(:organisation)
    get :edit, id: organisation
    assert_equal organisation, assigns(:organisation)
  end

  view_test "editing should not show the current organisation in the list of parent organisations" do
    organisation = create(:organisation)
    get :edit, id: organisation
    refute_select "#{parent_organisations_list_selector} option[value='#{organisation.id}']"
  end

  view_test "edit should show only departments in the list of parent organisations" do
    org1 = create(:organisation)
    org2 = create(:organisation)
    dept = create(:ministerial_department)
    get :edit, id: org1
    refute_select "#{parent_organisations_list_selector} option[value='#{org2.id}']"
    assert_select "#{parent_organisations_list_selector} option[value='#{dept.id}']"
  end

  view_test "editing should display a cancel link back to the list of organisations" do
    organisation = create(:organisation)
    get :edit, id: organisation
    assert_select ".or_cancel a[href='#{admin_organisation_path(organisation)}']"
  end

  view_test "editing shows roles for ordering in separate lists" do
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

    get :people, id: organisation

    assert_select "#minister_ordering input[name^='organisation[organisation_roles_attributes]'][value=#{organisation_ministerial_role.id}]"
    refute_select "#minister_ordering input[name^='organisation[organisation_roles_attributes]'][value=#{organisation_board_member_role.id}]"
    refute_select "#minister_ordering input[name^='organisation[organisation_roles_attributes]'][value=#{organisation_traffic_commissioner_role.id}]"
    refute_select "#minister_ordering input[name^='organisation[organisation_roles_attributes]'][value=#{organisation_scientific_role.id}]"

    assert_select "#board_member_ordering input[name^='organisation[organisation_roles_attributes]'][value=#{organisation_board_member_role.id}]"
    assert_select "#board_member_ordering input[name^='organisation[organisation_roles_attributes]'][value=#{organisation_scientific_role.id}]"
    refute_select "#board_member_ordering input[name^='organisation[organisation_roles_attributes]'][value=#{organisation_ministerial_role.id}]"
    refute_select "#board_member_ordering input[name^='organisation[organisation_roles_attributes]'][value=#{organisation_traffic_commissioner_role.id}]"

    assert_select "#traffic_commissioner_ordering input[name^='organisation[organisation_roles_attributes]'][value=#{organisation_traffic_commissioner_role.id}]"
    refute_select "#traffic_commissioner_ordering input[name^='organisation[organisation_roles_attributes]'][value=#{organisation_ministerial_role.id}]"
    refute_select "#traffic_commissioner_ordering input[name^='organisation[organisation_roles_attributes]'][value=#{organisation_board_member_role.id}]"
    refute_select "#traffic_commissioner_ordering input[name^='organisation[organisation_roles_attributes]'][value=#{organisation_scientific_role.id}]"

    assert_select "#military_ordering input[name^='organisation[organisation_roles_attributes]'][value=#{organisation_military_role.id}]"
    refute_select "#military_ordering input[name^='organisation[organisation_roles_attributes]'][value=#{organisation_ministerial_role.id}]"
    refute_select "#military_ordering input[name^='organisation[organisation_roles_attributes]'][value=#{organisation_board_member_role.id}]"
    refute_select "#military_ordering input[name^='organisation[organisation_roles_attributes]'][value=#{organisation_traffic_commissioner_role.id}]"
    refute_select "#military_ordering input[name^='organisation[organisation_roles_attributes]'][value=#{organisation_scientific_role.id}]"

    assert_select "#chief_professional_officer_ordering input[name^='organisation[organisation_roles_attributes]'][value=#{organisation_chief_professional_officer_role.id}]"
    refute_select "#chief_professional_officer_ordering input[name^='organisation[organisation_roles_attributes]'][value=#{organisation_ministerial_role.id}]"
    refute_select "#chief_professional_officer_ordering input[name^='organisation[organisation_roles_attributes]'][value=#{organisation_board_member_role.id}]"
    refute_select "#chief_professional_officer_ordering input[name^='organisation[organisation_roles_attributes]'][value=#{organisation_traffic_commissioner_role.id}]"
    refute_select "#chief_professional_officer_ordering input[name^='organisation[organisation_roles_attributes]'][value=#{organisation_scientific_role.id}]"
  end

  view_test "editing shows ministerial role and current person's name" do
    person = create(:person, forename: "John", surname: "Doe")
    ministerial_role = create(:ministerial_role, name: "Prime Minister")
    create(:role_appointment, person: person, role: ministerial_role, started_at: 1.day.ago)
    organisation = create(:organisation, roles: [ministerial_role])

    get :people, id: organisation

    assert_select "#minister_ordering label", text: /Prime Minister/i
    assert_select "#minister_ordering label", text: /John Doe/i
  end

  test "editing shows ministerial roles in their currently specified order" do
    junior_ministerial_role = create(:ministerial_role)
    senior_ministerial_role = create(:ministerial_role)
    organisation = create(:organisation)
    organisation_junior_ministerial_role = create(:organisation_role, organisation: organisation, role: junior_ministerial_role, ordering: 2)
    organisation_senior_ministerial_role = create(:organisation_role, organisation: organisation, role: senior_ministerial_role, ordering: 1)

    get :people, id: organisation

    assert_equal [organisation_senior_ministerial_role, organisation_junior_ministerial_role], assigns(:ministerial_organisation_roles)
  end

  test "editing shows board member roles in their currently specified order" do
    junior_board_member_role = create(:board_member_role)
    senior_board_member_role = create(:board_member_role)
    chief_scientific_advisor_role = create(:chief_scientific_advisor_role)

    organisation = create(:organisation)
    organisation_chief_scientific_advisor_role = create(:organisation_role, organisation: organisation, role: chief_scientific_advisor_role, ordering: 2)
    organisation_junior_board_member_role = create(:organisation_role, organisation: organisation, role: junior_board_member_role, ordering: 3)
    organisation_senior_board_member_role = create(:organisation_role, organisation: organisation, role: senior_board_member_role, ordering: 1)

    get :people, id: organisation

    assert_equal [
      organisation_senior_board_member_role,
      organisation_chief_scientific_advisor_role,
      organisation_junior_board_member_role
    ], assigns(:management_organisation_roles)
  end

  test "editing shows traffic commissioner roles in their currently specified order" do
    junior_traffic_commissioner_role = create(:traffic_commissioner_role)
    senior_traffic_commissioner_role = create(:traffic_commissioner_role)
    organisation = create(:organisation)
    organisation_junior_traffic_commissioner_role = create(:organisation_role, organisation: organisation, role: junior_traffic_commissioner_role, ordering: 2)
    organisation_senior_traffic_commissioner_role = create(:organisation_role, organisation: organisation, role: senior_traffic_commissioner_role, ordering: 1)

    get :people, id: organisation

    assert_equal [organisation_senior_traffic_commissioner_role, organisation_junior_traffic_commissioner_role], assigns(:traffic_commissioner_organisation_roles)
  end

  test "editing shows chief professional officer roles in their currently specified order" do
    junior_chief_professional_officer_role = create(:chief_professional_officer_role)
    senior_chief_professional_officer_role = create(:chief_professional_officer_role)
    organisation = create(:organisation)
    organisation_junior_chief_professional_officer_role = create(:organisation_role, organisation: organisation, role: junior_chief_professional_officer_role, ordering: 2)
    organisation_senior_chief_professional_officer_role = create(:organisation_role, organisation: organisation, role: senior_chief_professional_officer_role, ordering: 1)

    get :people, id: organisation

    assert_equal [organisation_senior_chief_professional_officer_role, organisation_junior_chief_professional_officer_role], assigns(:chief_professional_officer_roles)
  end

  test "editing shows special representative roles in their currently specified order" do
    junior_representative_role = create(:special_representative_role)
    senior_representative_role = create(:special_representative_role)
    organisation = create(:organisation)
    organisation_junior_representative_role = create(:organisation_role, organisation: organisation, role: junior_representative_role, ordering: 2)
    organisation_senior_representative_role = create(:organisation_role, organisation: organisation, role: senior_representative_role, ordering: 1)

    get :people, id: organisation

    assert_equal [organisation_senior_representative_role, organisation_junior_representative_role], assigns(:special_representative_organisation_roles)
  end

  view_test "editing does not display an empty ministerial roles section" do
    organisation = create(:organisation)
    get :people, id: organisation
    refute_select "#minister_ordering"
  end

  view_test "editing contains the relevant dom classes to facilitate the javascript ordering functionality" do
    organisation = create(:organisation, roles: [create(:ministerial_role)])
    get :people, id: organisation
    assert_select "fieldset#minister_ordering.sortable input.ordering[name^='organisation[organisation_roles_attributes]']"
  end

  view_test "editing allows entry of important board members only data to gds editors" do
    login_as :gds_editor
    junior_board_member_role = create(:board_member_role)
    senior_board_member_role = create(:board_member_role)

    organisation = create(:organisation)
    organisation_senior_board_member_role = create(:organisation_role, organisation: organisation, role: senior_board_member_role)
    organisation_junior_board_member_role = create(:organisation_role, organisation: organisation, role: junior_board_member_role)

    get :edit, id: organisation

    assert_select 'select#organisation_important_board_members option', count: 2
  end

  test "allows updating of organisation role ordering" do
    organisation = create(:organisation)
    ministerial_role = create(:ministerial_role)
    organisation_role = create(:organisation_role, organisation: organisation, role: ministerial_role, ordering: 1)

    put :update, id: organisation.id, organisation: {organisation_roles_attributes: {
      "0" => {id: organisation_role.id, ordering: "2"}
    }}

    assert_equal 2, organisation_role.reload.ordering
  end

  test "update with bad params does not update the organisation and renders the edit page" do
    ministerial_role = create(:ministerial_role)
    organisation = create(:organisation, name: 'org name')
    create(:organisation_role, organisation: organisation, role: ministerial_role)

    put :update, id: organisation, organisation: {name: ""}

    assert_response :success
    assert_template :edit

    assert_equal 'org name', organisation.reload.name
  end

  test "updating should modify the organisation" do
    organisation = create(:organisation, name: "Ministry of Sound")
    organisation_attributes = {
      name: "Ministry of Noise",
      description: "organisation-description",
      about_us: "organisation-about-us"
    }

    put :update, id: organisation, organisation: organisation_attributes

    organisation.reload
    assert_equal "Ministry of Noise", organisation.name
    assert_equal "organisation-description", organisation.description
    assert_equal "organisation-about-us", organisation.about_us
  end

  test "updating without a name should reshow the edit form" do
    organisation = create(:organisation, name: "Ministry of Sound")

    put :update, id: organisation, organisation: {name: ""}

    assert_template "organisations/edit"
  end

  test "update should remove all related topics if none specified" do
    organisation_attributes = {name: "Ministry of Sound"}
    organisation = create(:organisation,
      organisation_attributes.merge(topics: [create(:topic)])
    )

    put :update, id: organisation, organisation: organisation_attributes.merge(classification_ids: [""])

    organisation.reload
    assert_equal [], organisation.topics
  end

  test "update should remove all related mainstream categories if none specified" do
    organisation_attributes = {name: "Ministry of Sound"}
    organisation = create(:organisation,
      organisation_attributes.merge(mainstream_categories: [create(:mainstream_category)])
    )

    put :update, id: organisation, organisation: organisation_attributes.merge(mainstream_category_ids: [""])

    organisation.reload
    assert_equal [], organisation.mainstream_categories
  end

  test "update removes absent mainstream categories via nested attributes" do
    category1 = create(:mainstream_category)
    category2 = create(:mainstream_category)
    organisation_attributes = {name: "Ministry of Sound"}
    organisation = create(:organisation, organisation_attributes.merge(mainstream_categories: [category1, category2]))
    category1_join = organisation.organisation_mainstream_categories.where(mainstream_category_id: category1).first
    category2_join = organisation.organisation_mainstream_categories.where(mainstream_category_id: category2).first

    put :update, id: organisation,
                 organisation: organisation_attributes.merge( organisation_mainstream_categories_attributes: [ {mainstream_category_id: category1.id, ordering: "0", id: category1_join.id},
                                                                                                               {mainstream_category_id: "", ordering: "1", id: category2_join.id} ])

    assert_equal [category1], organisation.reload.mainstream_categories
  end

  test "update should remove all parent organisations if none specified" do
    organisation_attributes = {name: "Ministry of Sound"}
    organisation = create(:organisation,
      organisation_attributes.merge(parent_organisation_ids: [create(:organisation).id])
    )

    put :update, id: organisation, organisation: organisation_attributes.merge(parent_organisation_ids: [""])

    organisation.reload
    assert_equal [], organisation.parent_organisations
  end

  test "updating should allow ordering of featured editions" do
    organisation = create(:organisation)
    edition_association_1 = create(:featured_edition_organisation, organisation: organisation)
    edition_association_2 = create(:featured_edition_organisation, organisation: organisation)
    edition_association_3 = create(:featured_edition_organisation, organisation: organisation)

    put :update, id: organisation, organisation: {
      edition_organisations_attributes: {
        "0" => {"id" => edition_association_1.id, "ordering" => "3"},
        "1" => {"id" => edition_association_2.id, "ordering" => "2"},
        "2" => {"id" => edition_association_3.id, "ordering" => "1"}
      }
    }

    assert_equal 3, edition_association_1.reload.ordering
    assert_equal 2, edition_association_2.reload.ordering
    assert_equal 1, edition_association_3.reload.ordering
  end

  test "updating order of featured editions should not lose topics or parent organisations" do
    topic = create(:topic)
    parent_organisation = create(:organisation)
    organisation = create(:organisation, topics: [topic], parent_organisations: [parent_organisation])

    put :update, id: organisation, organisation: {edition_organisations_attributes: {}}

    assert_equal [topic], organisation.reload.topics
    assert_equal [parent_organisation], organisation.reload.parent_organisations
  end

  test "GET on :about" do
    organisation = create(:organisation)
    get :about, id: organisation

    assert_response :success
    assert_template :about
    assert_equal organisation, assigns(:organisation)
  end

  test "GET on :document_series" do
    organisation = create(:organisation)
    get :document_series, id: organisation

    assert_response :success
    assert_template :document_series
    assert_equal organisation.document_series, assigns(:document_series)
  end
end
