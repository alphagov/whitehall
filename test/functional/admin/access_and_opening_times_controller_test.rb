require "test_helper"

class Admin::AccessAndOpeningTimesControllerTest < ActionController::TestCase
  setup do
    login_as :gds_editor
  end

  should_be_an_admin_controller

  test "GET on :edit loads the organisation as accessible if worldwide_office_id is not supplied" do
    worldwide_organisation = create(:worldwide_organisation)
    get :edit, params: { worldwide_organisation_id: worldwide_organisation }

    assert_response :success
    assert_template :edit
    assert_equal worldwide_organisation, assigns(:accessible)
    assert assigns(:access_and_opening_times).is_a?(AccessAndOpeningTimesForm)
    assert_nil assigns(:access_and_opening_times).body
  end

  test "GET on :edit loads the office as accessible if worldwide_office_id is supplied" do
    worldwide_organisation = create(:worldwide_organisation)
    worldwide_office = create(:worldwide_office, worldwide_organisation:)
    get :edit, params: { worldwide_organisation_id: worldwide_organisation, worldwide_office_id: worldwide_office }

    assert_response :success
    assert_template :edit
    assert_equal worldwide_office, assigns(:accessible)
    assert assigns(:access_and_opening_times).is_a?(AccessAndOpeningTimesForm)
    assert_nil assigns(:access_and_opening_times).body
  end

  test "GET on :edit sets the default body for an office if a default is available" do
    worldwide_organisation = create(:worldwide_organisation, default_access_and_opening_times: "default from org")
    worldwide_office = create(:worldwide_office, worldwide_organisation:)

    get :edit, params: { worldwide_organisation_id: worldwide_organisation, worldwide_office_id: worldwide_office }

    assert_response :success
    assert_equal worldwide_office, assigns(:accessible)
    assert_equal "default from org", assigns(:access_and_opening_times).body
  end

  test "PUT on :update saves the access and opening times details to the organisation" do
    worldwide_organisation = create(:worldwide_organisation)
    put :update, params: { worldwide_organisation_id: worldwide_organisation, access_and_opening_times_form: { body: "body text" } }

    assert_equal "body text", worldwide_organisation.reload.default_access_and_opening_times
    assert_redirected_to access_info_admin_worldwide_organisation_path(worldwide_organisation)
  end

  test "PUT on :update saves access info to an office and redirects to the offices page for the organisation" do
    worldwide_organisation = create(:worldwide_organisation)
    worldwide_office = create(:worldwide_office, worldwide_organisation:)
    put :update, params: { worldwide_organisation_id: worldwide_organisation, worldwide_office_id: worldwide_office, access_and_opening_times_form: { body: "custom body text" } }

    assert_equal "custom body text", worldwide_office.reload.access_and_opening_times
    assert_redirected_to admin_worldwide_organisation_worldwide_offices_path(worldwide_organisation)
  end

  view_test "PUT on :update displays errors if access and opening times info is invalid" do
    worldwide_organisation = create(:worldwide_organisation)
    put :update, params: { worldwide_organisation_id: worldwide_organisation, access_and_opening_times_form: { body: "" } }

    assert_nil worldwide_organisation.reload.access_and_opening_times
    assert_template :edit
    assert_select "form" do
      assert_select ".field_with_errors textarea[name=?]", "access_and_opening_times_form[body]"
    end
  end

  test "the office is loaded scoped to the organisation to avoid slug clashes" do
    worldwide_organisation = create(:worldwide_organisation)
    office_for_other_org = create(:worldwide_office)

    assert_raise ActiveRecord::RecordNotFound do
      get :edit, params: { worldwide_organisation_id: worldwide_organisation, worldwide_office_id: office_for_other_org }
    end

    assert_raise ActiveRecord::RecordNotFound do
      put :update, params: { worldwide_organisation_id: worldwide_organisation, worldwide_office_id: office_for_other_org, access_and_opening_times_form: { body: "body" } }
    end
  end
end
