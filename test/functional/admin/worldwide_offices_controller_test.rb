require "test_helper"

class Admin::WorldwideOfficesControllerTest < ActionController::TestCase
  setup do
    login_as :gds_editor
  end

  should_be_an_admin_controller

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

    assert_redirected_to admin_worldwide_office_path(worldwide_office)
  end

  view_test "shows validation errors on invalid worldwide office" do
    post :create, worldwide_office: {
      name: "Office",
    }

    assert_select 'form#worldwide_office_new .errors'
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
    assert_redirected_to admin_worldwide_office_path(worldwide_office)
  end

  test "setting the main contact" do
    contacts = [create(:contact), create(:contact)]
    worldwide_office = create(:worldwide_office, contacts: contacts)
    put :set_main_contact, id: worldwide_office.id, worldwide_office: { main_contact_id: contacts.last.id }

    assert_equal contacts.last, worldwide_office.reload.main_contact
    assert_equal "Main contact updated successfully", flash[:notice]
    assert_redirected_to contacts_admin_worldwide_office_path(worldwide_office)
  end

  test "destroys an existing object" do
    office = create(:worldwide_office)
    count = WorldwideOffice.count
    delete :destroy, id: office.id
    assert_equal count - 1, WorldwideOffice.count
  end

  view_test "shows the name summary and description of the worldwide office" do
    office = create(:worldwide_office, name: "Ministry of Silly Walks in Madrid",
      summary: "We have a nice office in madrid",
      description: "# Office\nOur office is on the main road\n")

    get :show, id: office

    assert_select_object office do
      assert_select "h1", office.name
      assert_select ".summary", office.summary
      assert_select ".description" do
        assert_select "h1", "Office"
        assert_select "p", "Our office is on the main road"
      end
    end
  end
end
