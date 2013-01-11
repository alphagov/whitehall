require "test_helper"

class Admin::WorldwideOfficesControllerTest < ActionController::TestCase
  setup do
    login_as :gds_editor
  end

  should_be_an_admin_controller
  should_allow_social_media_management_for :worldwide_office

  test "shows a list of worldwide offices" do
    office = create(:worldwide_office)
    WorldwideOffice.stubs(all: [office])
    get :index
    assert_equal [office], assigns(:worldwide_offices)
  end

  test "presents a form to create a new worldwide office" do
    get :new
    assert_template "worldwide_offices/new"
    assert_kind_of WorldwideOffice, assigns(:worldwide_office)
  end

  test "creates a worldwide office" do
    post :create, worldwide_office: {
      name: "Office",
      summary: "Summary",
      description: "Description"
    }

    worldwide_office = WorldwideOffice.last
    assert_kind_of WorldwideOffice, worldwide_office
    assert_equal "Office", worldwide_office.name
    assert_equal "Summary", worldwide_office.summary
    assert_equal "Description", worldwide_office.description

    assert_redirected_to admin_worldwide_offices_path
  end

  test "shows an edit page for an existing worldwide office" do
    office = create(:worldwide_office)
    get :edit, id: office.id
  end

  test "updates an existing objects with new values" do
    office = create(:worldwide_office)
    put :update, id: office.id, worldwide_office: {
      name: "New name"
    }
    worldwide_office = WorldwideOffice.last
    assert_equal "New name", worldwide_office.name
  end

  test "destroys an existing object" do
    office = create(:worldwide_office)
    count = WorldwideOffice.count
    delete :destroy, id: office.id
    assert_equal count - 1, WorldwideOffice.count
  end
end
