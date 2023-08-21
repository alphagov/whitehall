require "test_helper"

class Admin::WorldwideOrganisationsControllerTest < ActionController::TestCase
  setup do
    login_as :gds_admin
  end

  should_be_an_admin_controller

  test "shows a list of worldwide organisations" do
    organisation = create(:worldwide_organisation)
    get :index
    assert_equal [organisation], assigns(:worldwide_organisations)
  end

  test "presents a form to create a new worldwide organisation" do
    get :new
    assert_template :new
    assert_kind_of WorldwideOrganisation, assigns(:worldwide_organisation)
  end

  test "creates a worldwide organisation" do
    post :create,
         params: {
           worldwide_organisation: {
             name: "Organisation",
           },
         }

    worldwide_organisation = WorldwideOrganisation.last
    assert_kind_of WorldwideOrganisation, worldwide_organisation
    assert_equal "Organisation created successfully", flash[:notice]
    assert_equal "Organisation", worldwide_organisation.name

    assert_redirected_to admin_worldwide_organisation_path(worldwide_organisation)
  end

  view_test "shows validation errors on invalid worldwide organisation" do
    post :create,
         params: {
           worldwide_organisation: {
             name: "",
           },
         }

    assert_select ".govuk-error-summary"
  end

  test "shows an edit page for an existing worldwide organisation" do
    organisation = create(:worldwide_organisation)
    get :edit, params: { id: organisation.id }
  end

  test "updates an existing objects with new values" do
    organisation = create(:worldwide_organisation)
    put :update,
        params: {
          id: organisation.id,
          worldwide_organisation: {
            name: "New name",
            default_news_image_attributes: {
              file: upload_fixture("minister-of-funk.960x640.jpg"),
            },
          },
        }
    worldwide_organisation = WorldwideOrganisation.last
    assert_equal "New name", worldwide_organisation.name
    assert_equal "minister-of-funk.960x640.jpg", worldwide_organisation.default_news_image.file.file.filename
    assert_equal "Organisation updated successfully", flash[:notice]
    assert_redirected_to admin_worldwide_organisation_path(worldwide_organisation)
  end

  test "GET :choose_main_office calls correctly" do
    organisation = create(:worldwide_organisation)

    get :choose_main_office, params: { id: organisation.id }

    assert_response :success
    assert_equal organisation, assigns(:worldwide_organisation)
  end

  view_test "GET :choose_main_office uses radios when 5 or less offices exist" do
    organisation = create(:worldwide_organisation)
    5.times { create(:worldwide_office, worldwide_organisation: organisation) }

    get :choose_main_office, params: { id: organisation.id }

    assert_select ".govuk-radios"
    refute_select "select#worldwide_organisation_main_office_id"
  end

  view_test "GET :choose_main_office uses a select when 6 or more offices exist" do
    organisation = create(:worldwide_organisation)
    6.times { create(:worldwide_office, worldwide_organisation: organisation) }

    get :choose_main_office, params: { id: organisation.id }

    assert_select "select#worldwide_organisation_main_office_id"
    refute_select ".govuk-radios"
  end

  test "setting the main office" do
    offices = [create(:worldwide_office), create(:worldwide_office)]
    worldwide_organisation = create(:worldwide_organisation, offices:)
    put :set_main_office, params: { id: worldwide_organisation.id, worldwide_organisation: { main_office_id: offices.last.id } }

    assert_equal offices.last, worldwide_organisation.reload.main_office
    assert_equal "Main office updated successfully", flash[:notice]
    assert_redirected_to admin_worldwide_organisation_worldwide_offices_path(worldwide_organisation)
  end

  test "destroys an existing object" do
    organisation = create(:worldwide_organisation)

    page = create(
      :published_worldwide_organisation_corporate_information_page,
      worldwide_organisation: organisation,
    )

    create(
      :published_worldwide_organisation_corporate_information_page,
      worldwide_organisation: organisation,
      document: page.document,
    )

    count = WorldwideOrganisation.count
    delete :destroy, params: { id: organisation.id }
    assert_equal "Organisation deleted successfully", flash[:notice]
    assert_equal count - 1, WorldwideOrganisation.count
  end

  test "GET :confirm_destroy calls correctly" do
    organisation = create(:worldwide_organisation)

    get :confirm_destroy, params: { id: organisation.id }

    assert_response :success
  end

  test "GET :show calls correctly" do
    organisation = create(:worldwide_organisation, name: "Ministry of Silly Walks in Madrid")

    get :show, params: { id: organisation }

    assert_response :success
    assert_equal organisation, assigns(:worldwide_organisation)
  end
end
