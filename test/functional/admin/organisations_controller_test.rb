require "test_helper"

class Admin::OrganisationsControllerTest < ActionController::TestCase
  setup do
    login_as :policy_writer
  end

  should_be_an_admin_controller

  test "index should list all the organisations in alphabetical order" do
    organisations = [create(:organisation, name: "org 1"), create(:organisation, name: "org 2")]
    get :index
    assert_equal organisations, assigns(:organisations)
  end

  test "should allow entry of new organisation data" do
    get :new
    assert_template "organisations/new"
    assert_select "textarea[name='organisation[description]']"
    assert_select "textarea[name='organisation[about_us]'].previewable.govspeak"
    assert_select "#govspeak_help"
    assert_select parent_organisations_list_selector
    assert_select organisation_type_list_selector
    assert_select organisation_policy_areas_list_selector
    assert_select "input[type=text][name='organisation[contacts_attributes][0][description]']"
    assert_select "textarea[name='organisation[contacts_attributes][0][address]']"
    assert_select "input[type=text][name='organisation[contacts_attributes][0][postcode]']"
    assert_select "input[type=text][name='organisation[contacts_attributes][0][contact_numbers_attributes][0][label]']"
    assert_select "input[type=text][name='organisation[contacts_attributes][0][contact_numbers_attributes][0][number]']"
  end

  test "should allow creation of an organisation without any contact details" do
    organisation_type = create(:organisation_type)

    post :create, organisation: {
      name: "Anything",
      organisation_type_id: organisation_type.id,
      contacts_attributes: [{description: "", contact_numbers_attributes: [{label: "", number: ""}]}]
    }

    organisation = Organisation.last
    assert_kind_of Organisation, organisation
    assert_equal "Anything", organisation.name
  end

  test "creating should create a new Organisation" do
    attributes = attributes_for(:organisation,
      description: "organisation-description",
      about_us: "organisation-about-us"
    )

    organisation_type = create(:organisation_type)
    policy_area = create(:policy_area)

    post :create, organisation: attributes.merge(
      organisation_type_id: organisation_type.id,
      policy_area_ids: [policy_area.id],
      contacts_attributes: [{description: "Enquiries", contact_numbers_attributes: [{label: "Fax", number: "020712435678"}]}]
    )

    assert organisation = Organisation.last
    assert_equal attributes[:name], organisation.name
    assert_equal attributes[:description], organisation.description
    assert_equal attributes[:about_us], organisation.about_us
    assert_equal 1, organisation.contacts.count
    assert_equal "Enquiries", organisation.contacts[0].description
    assert_equal 1, organisation.contacts[0].contact_numbers.count
    assert_equal "Fax", organisation.contacts[0].contact_numbers[0].label
    assert_equal "020712435678", organisation.contacts[0].contact_numbers[0].number
    assert_equal policy_area, organisation.policy_areas.first
  end

  test "creating should redirect back to the index" do
    organisation_type = create(:organisation_type)
    attributes = attributes_for(:organisation)
    post :create, organisation: attributes.merge(
      organisation_type_id: organisation_type.id
    )

    assert_redirected_to admin_organisations_path
  end

  test "creating without a name should reshow the edit form" do
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
      organisation_type_id: organisation_type.id,
      parent_organisation_ids: [parent_org_1.id, parent_org_2.id]
    )
    created_organisation = Organisation.last
    assert_equal [parent_org_1, parent_org_2], created_organisation.parent_organisations
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

  test "creating with blank numbers ignores blank numbers" do
    attributes = attributes_for(:organisation,
      description: "organisation-description",
      about_us: "organisation-about-us"
    )

    organisation_type = create(:organisation_type)
    policy_area = create(:policy_area)

    post :create, organisation: attributes.merge(
      organisation_type_id: organisation_type.id,
      policy_area_ids: [policy_area.id],
      contacts_attributes: {"0" => {
        description: "Enquiries",
        contact_numbers_attributes: {
          "0" => { label: " ", number: " " },
          "1" => { label: " ", number: " " }
        }
      }}
    )

    created_organisation = Organisation.last
    assert_not_nil created_organisation
    assert_equal 0, created_organisation.contacts.first.contact_numbers.size
  end

  test "editing should load the requested organisation" do
    organisation = create(:organisation)
    get :edit, id: organisation
    assert_equal organisation, assigns(:organisation)
  end

  test "editing shouldn't show the current organisation in the list of parent organisations" do
    organisation = create(:organisation)
    get :edit, id: organisation
    refute_select "#{parent_organisations_list_selector} option[value='#{organisation.id}']"
  end

  test "editing should display a cancel link back to the list of organisations" do
    organisation = create(:organisation)
    get :edit, id: organisation
    assert_select ".or_cancel a[href='#{admin_organisations_path}']"
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

  test "updating with an empty contact shouldn't create that contact" do
    organisation = create(:organisation, name: "Ministry of Sound")
    organisation_attributes = {
      name: "Ministry of Sound",
      contacts_attributes: [{description: "", number: ""}]
    }

    put :update, id: organisation, organisation: organisation_attributes

    assert_equal 0, organisation.contacts.count
  end

  test "update should remove all related policy areas if none specified" do
    organisation_attributes = {name: "Ministry of Sound"}
    organisation = create(:organisation,
      organisation_attributes.merge(policy_area_ids: [create(:policy_area).id])
    )

    put :update, id: organisation, organisation: organisation_attributes

    organisation.reload
    assert_equal [], organisation.policy_areas
  end

  test "update should remove all parent organisations if none specified" do
    organisation_attributes = {name: "Ministry of Sound"}
    organisation = create(:organisation,
      organisation_attributes.merge(parent_organisation_ids: [create(:organisation).id])
    )

    put :update, id: organisation, organisation: organisation_attributes

    organisation.reload
    assert_equal [], organisation.parent_organisations
  end

  test "updating with blank numbers destroys those blank numbers" do
    organisation = create(:organisation)
    contact = create(:contact, organisation: organisation)
    contact_number = create(:contact_number, contact: contact)

    put :update, id: organisation, organisation: { contacts_attributes: { 0 => {
      id: contact,
      contact_numbers_attributes: {
        0 => { label: " ", number: " ", id: contact_number }
      }
    }}}

    contact.reload
    assert_equal 0, contact.contact_numbers.count
  end
end
