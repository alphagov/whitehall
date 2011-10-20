require "test_helper"

class Admin::OrganisationsControllerTest < ActionController::TestCase
  setup do
    @user = login_as "George"
  end

  test "is an admin controller" do
    assert @controller.is_a?(Admin::BaseController), "the controller should have the behaviour of an Admin::BaseController"
  end

  test "index should list all the organisations" do
    organisations = [create(:organisation), create(:organisation)]
    get :index
    assert_equal organisations, assigns(:organisations)
  end

  test "should allow entry of new organisation data" do
    get :new
    assert_template "organisations/new"
  end

  test "creating should create a new Organisation" do
    post :create, organisation: {name: "Ministry of Sound", address: "Clubtown, London",
                                 email: "minister@beatsinternational.co.uk",
                                 phone_numbers_attributes: [
                                   {description: "Fax", number: "020712435678"}
                                 ]}

    organisation = Organisation.last
    assert_equal "Ministry of Sound", organisation.name
    assert_equal 1, organisation.phone_numbers.count
    assert_equal "Fax", organisation.phone_numbers.first.description
  end

  test "creating should redirect back to the index" do
    post :create, organisation: {name: "Ministry of Sound", address: "Clubtown, London",
                                 email: "minister@beatsinternational.co.uk",
                                 phone_numbers_attributes: [
                                   {description: "Fax", number: "020712435678"}
                                 ]}

    assert_redirected_to admin_organisations_path
  end

  test "editing should load the requested organisation" do
    organisation = create(:organisation)
    get :edit, id: organisation.to_param
    assert_equal organisation, assigns(:organisation)
  end

  test "updating should modify the organisation" do
    organisation = create(:organisation, name: "Ministry of Sound")
    organisation_attributes = {name: "Ministry of Noise"}

    put :update, id: organisation.to_param, organisation: organisation_attributes

    assert_equal "Ministry of Noise", organisation.reload.name
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