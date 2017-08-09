require "test_helper"

class Admin::WorldwideOrganisationsControllerTest < ActionController::TestCase
  setup do
    login_as :gds_editor
  end

  should_be_an_admin_controller

  test "shows a list of worldwide organisations" do
    organisation = create(:worldwide_organisation)
    get :index
    assert_equal [organisation], assigns(:worldwide_organisations)
  end

  test "presents a form to create a new worldwide organisation" do
    get :new
    assert_template "worldwide_organisations/new"
    assert_kind_of WorldwideOrganisation, assigns(:worldwide_organisation)
  end

  test "creates a worldwide organisation" do
    post :create, params: {
      worldwide_organisation: {
        name: "Organisation",
      }
    }

    worldwide_organisation = WorldwideOrganisation.last
    assert_kind_of WorldwideOrganisation, worldwide_organisation
    assert_equal "Organisation", worldwide_organisation.name

    assert_redirected_to admin_worldwide_organisation_path(worldwide_organisation)
  end

  view_test "shows validation errors on invalid worldwide organisation" do
    post :create, params: {
      worldwide_organisation: {
        name: "",
      }
    }

    assert_select 'form#new_worldwide_organisation .errors'
  end

  test "shows an edit page for an existing worldwide organisation" do
    organisation = create(:worldwide_organisation)
    get :edit, params: { id: organisation.id }
  end

  test "updates an existing objects with new values" do
    organisation = create(:worldwide_organisation)
    put :update, params: {
      id: organisation.id, worldwide_organisation: {
        name: "New name",
        default_news_image_attributes: {
          file: fixture_file_upload('minister-of-funk.960x640.jpg')
        },
      }
    }
    worldwide_organisation = WorldwideOrganisation.last
    assert_equal "New name", worldwide_organisation.name
    assert_equal 'minister-of-funk.960x640.jpg', worldwide_organisation.default_news_image.file.file.filename
    assert_redirected_to admin_worldwide_organisation_path(worldwide_organisation)
  end

  test "setting the main office" do
    offices = [create(:worldwide_office), create(:worldwide_office)]
    worldwide_organisation = create(:worldwide_organisation, offices: offices)
    put :set_main_office, params: { id: worldwide_organisation.id, worldwide_organisation: { main_office_id: offices.last.id } }

    assert_equal offices.last, worldwide_organisation.reload.main_office
    assert_equal "Main office updated successfully", flash[:notice]
    assert_redirected_to admin_worldwide_organisation_worldwide_offices_path(worldwide_organisation)
  end

  test "viewing office access details with no default assigns a new one" do
    worldwide_organisation = create(:worldwide_organisation)
    get :access_info, params: { id: worldwide_organisation }

    assert_response :success
    assert_template :access_info
    assert assigns(:access_and_opening_times).is_a?(AccessAndOpeningTimes)
    assert assigns(:access_and_opening_times).new_record?
    assert_equal worldwide_organisation, assigns(:worldwide_organisation)
  end

  test "destroys an existing object" do
    organisation = create(:worldwide_organisation)

    page = create(:published_worldwide_organisation_corporate_information_page,
                  worldwide_organisation: organisation)

    create(:published_worldwide_organisation_corporate_information_page,
           worldwide_organisation: organisation,
           document: page.document)

    count = WorldwideOrganisation.count
    delete :destroy, params: { id: organisation.id }
    assert_equal count - 1, WorldwideOrganisation.count
  end

  view_test "shows the name summary and description of the worldwide organisation" do
    organisation = create(:worldwide_organisation, name: "Ministry of Silly Walks in Madrid")
    about_us = create(:about_corporate_information_page,
                      organisation: nil, worldwide_organisation: organisation,
                      summary: "We have a nice organisation in madrid",
                      body: "# Organisation\nOur organisation is on the main road\n")

    get :show, params: { id: organisation }

    assert_select_object organisation do
      assert_select "h1", organisation.name
      assert_select ".summary", about_us.summary
      assert_select ".description" do
        assert_select "h1", "Organisation"
        assert_select "p", "Our organisation is on the main road"
      end
    end
  end
end
