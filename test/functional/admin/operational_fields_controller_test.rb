require "test_helper"

class Admin::OperationalFieldsControllerTest < ActionController::TestCase
  setup do
    login_as :gds_editor
  end

  should_be_an_admin_controller
  should_require_fatality_handling_permission_to_access :operational_field, :index, :new, :edit

  test "index should list operational fields ordered alphabetically by name" do
    team_b = create(:operational_field, name: "field-b")
    team_a = create(:operational_field, name: "field-a")

    get :index

    assert_equal [team_a, team_b], assigns(:operational_fields)
  end

  view_test "index should provide link to edit existing operational field" do
    operational_field = create(:operational_field)

    get :index

    assert_select_object(operational_field) do
      assert_select "a[href='#{edit_admin_operational_field_path(operational_field)}']"
    end
  end

  test "new should build a new operational field" do
    get :new

    refute_nil operational_field = assigns(:operational_field)
    assert_instance_of(OperationalField, operational_field)
  end

  view_test "new should display operational field form" do
    get :new

    assert_select "form[action=?]", admin_operational_fields_path do
      assert_select "input[name='operational_field[name]']"
    end
  end

  test "create should create a new operational field" do
    post :create, params: { operational_field: { name: "field-a", description: "desc" } }

    operational_field = OperationalField.last
    refute_nil operational_field
    assert_equal "field-a", operational_field.name
    assert_equal "desc", operational_field.description
  end

  test "create should redirect to operational field list on success" do
    post :create, params: { operational_field: { name: "field-a" } }

    assert_redirected_to admin_operational_fields_path
  end

  view_test "create should re-render form with errors on failure" do
    create(:operational_field, name: "field-a")

    post :create, params: { operational_field: { name: "field-a" } }

    assert_template "new"
    assert_select ".errors"
  end

  view_test "edit should display operational field form" do
    operational_field = create(:operational_field, name: "field-a", description: "description of field")

    get :edit, params: { id: operational_field }

    assert_select "form[action=?]", admin_operational_field_path(operational_field) do
      assert_select "input[name='operational_field[name]'][value='field-a']"
      assert_select "textarea[name='operational_field[description]']", "description of field"
    end
  end

  test "udpate should modify operational field" do
    operational_field = create(:operational_field, name: "original")

    put :update, params: { id: operational_field, operational_field: { name: "new", description: "new desc" } }

    operational_field.reload
    assert_equal "new", operational_field.name
    assert_equal "new desc", operational_field.description
  end
end
