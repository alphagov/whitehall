require "test_helper"

class Admin::OrganisationsControllerTest < ActionController::TestCase
  setup do
    @user = login_as :policy_writer
  end

  test_controller_is_a Admin::BaseController

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
  end

  test "creating should create a new Organisation" do
    organisation_type = create(:organisation_type)
    attributes = attributes_for(:organisation,
      description: "organisation-description",
      about_us: "organisation-about-us"
    )
    post :create, organisation: attributes.merge(
      organisation_type_id: organisation_type.id,
      phone_numbers_attributes: [{description: "Fax", number: "020712435678"}]
    )

    assert organisation = Organisation.last
    assert_equal attributes[:name], organisation.name
    assert_equal attributes[:description], organisation.description
    assert_equal attributes[:about_us], organisation.about_us
    assert_equal 1, organisation.phone_numbers.count
    assert_equal "Fax", organisation.phone_numbers.first.description
  end

  test "creating should redirect back to the index" do
    organisation_type = create(:organisation_type)
    attributes = attributes_for(:organisation)
    post :create, organisation: attributes.merge(
      organisation_type_id: organisation_type.id,
      phone_numbers_attributes: [{description: "Fax", number: "020712435678"}]
    )

    assert_redirected_to admin_organisations_path
  end

  test "creating without a name should reshow the edit form" do
    attributes = attributes_for(:organisation)
    post :create, organisation: attributes.merge(
      name: '',
      phone_numbers_attributes: [{description: "Fax", number: "020712435678"}]
    )

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

  test "editing should load the requested organisation" do
    organisation = create(:organisation)
    get :edit, id: organisation.to_param
    assert_equal organisation, assigns(:organisation)
  end

  test "editing shouldn't show the current organisation in the list of parent organisations" do
    organisation = create(:organisation)
    get :edit, id: organisation.to_param
    assert_select "#{parent_organisations_list_selector} option[value='#{organisation.id}']", false
  end

  test "updating should modify the organisation" do
    organisation = create(:organisation, name: "Ministry of Sound")
    organisation_attributes = {
      name: "Ministry of Noise",
      description: "organisation-description",
      about_us: "organisation-about-us"
    }

    put :update, id: organisation.to_param, organisation: organisation_attributes

    organisation.reload
    assert_equal "Ministry of Noise", organisation.name
    assert_equal "organisation-description", organisation.description
    assert_equal "organisation-about-us", organisation.about_us
  end

  test "updating without a name should reshow the edit form" do
    organisation = create(:organisation, name: "Ministry of Sound")

    put :update, id: organisation.to_param, organisation: {name: ""}

    assert_template "organisations/edit"
  end

  test "updating with an empty phone number shouldn't create that phone number" do
    organisation = create(:organisation, name: "Ministry of Sound")
    organisation_attributes = {
      name: "Ministry of Sound",
      phone_numbers_attributes: [{description: "", number: ""}]
    }

    put :update, id: organisation.to_param, organisation: organisation_attributes

    assert_equal 0, organisation.phone_numbers.count
  end
end