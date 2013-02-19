require "test_helper"

class Admin::WorldwideOrganisationsControllerTest < ActionController::TestCase
  setup do
    login_as :gds_editor
  end

  should_be_an_admin_controller

  test "shows a list of worldwide organisations" do
    organisation = create(:worldwide_organisation)
    WorldwideOrganisation.stubs(all: [organisation])
    get :index
    assert_equal [organisation], assigns(:worldwide_organisations)
  end

  test "presents a form to create a new worldwide organisation" do
    get :new
    assert_template "worldwide_organisations/new"
    assert_kind_of WorldwideOrganisation, assigns(:worldwide_organisation)
  end

  test "creates a worldwide organisation" do
    post :create, worldwide_organisation: {
      name: "Organisation",
      summary: "Summary",
      description: "Description"
    }

    worldwide_organisation = WorldwideOrganisation.last
    assert_kind_of WorldwideOrganisation, worldwide_organisation
    assert_equal "Organisation", worldwide_organisation.name
    assert_equal "Summary", worldwide_organisation.summary
    assert_equal "Description", worldwide_organisation.description

    assert_redirected_to admin_worldwide_organisation_path(worldwide_organisation)
  end

  view_test "shows validation errors on invalid worldwide organisation" do
    post :create, worldwide_organisation: {
      name: "Organisation",
    }

    assert_select 'form#worldwide_organisation_new .errors'
  end

  test "shows an edit page for an existing worldwide organisation" do
    organisation = create(:worldwide_organisation)
    get :edit, id: organisation.id
  end

  test "updates an existing objects with new values" do
    organisation = create(:worldwide_organisation)
    put :update, id: organisation.id, worldwide_organisation: {
      name: "New name"
    }
    worldwide_organisation = WorldwideOrganisation.last
    assert_equal "New name", worldwide_organisation.name
    assert_redirected_to admin_worldwide_organisation_path(worldwide_organisation)
  end

  test "setting the main contact" do
    contacts = [create(:contact), create(:contact)]
    worldwide_organisation = create(:worldwide_organisation, contacts: contacts)
    put :set_main_contact, id: worldwide_organisation.id, worldwide_organisation: { main_contact_id: contacts.last.id }

    assert_equal contacts.last, worldwide_organisation.reload.main_contact
    assert_equal "Main contact updated successfully", flash[:notice]
    assert_redirected_to contacts_admin_worldwide_organisation_path(worldwide_organisation)
  end

  test "destroys an existing object" do
    organisation = create(:worldwide_organisation)
    count = WorldwideOrganisation.count
    delete :destroy, id: organisation.id
    assert_equal count - 1, WorldwideOrganisation.count
  end

  view_test "shows the name summary and description of the worldwide organisation" do
    organisation = create(:worldwide_organisation, name: "Ministry of Silly Walks in Madrid",
      summary: "We have a nice organisation in madrid",
      description: "# Organisation\nOur organisation is on the main road\n")

    get :show, id: organisation

    assert_select_object organisation do
      assert_select "h1", organisation.name
      assert_select ".summary", organisation.summary
      assert_select ".description" do
        assert_select "h1", "Organisation"
        assert_select "p", "Our organisation is on the main road"
      end
    end
  end
end
