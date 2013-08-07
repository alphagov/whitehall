require 'test_helper'

class Admin::AccessAndOpeningTimesControllerTest < ActionController::TestCase
  setup do
    login_as :gds_editor
  end

  should_be_an_admin_controller

  test "GET on :edit assigns a new instance if one does not already exist" do
    worldwide_organisation = create(:worldwide_organisation)
    get :edit, worldwide_organisation_id: worldwide_organisation

    assert_response :success
    assert_template :edit
    assert_equal worldwide_organisation, assigns(:accessible)
    assert assigns(:access_and_opening_times).is_a?(AccessAndOpeningTimes)
    assert assigns(:access_and_opening_times).new_record?
    assert_equal worldwide_organisation, assigns(:access_and_opening_times).accessible
  end

  test "GET on :edit loads the access and opening times if one exists" do
    worldwide_organisation = create(:worldwide_organisation)
    access_and_opening_times = create(:access_and_opening_times, accessible: worldwide_organisation)
    get :edit, worldwide_organisation_id: worldwide_organisation

    assert_response :success
    assert_template :edit
    assert_equal worldwide_organisation, assigns(:accessible)
    assert_equal access_and_opening_times, assigns(:access_and_opening_times)
  end

  test "GET on :edit loads the office as accessible if worldwide_office_id is supplied" do
    worldwide_organisation = create(:worldwide_organisation)
    worldwide_office = create(:worldwide_office, worldwide_organisation: worldwide_organisation)
    get :edit, worldwide_organisation_id: worldwide_organisation, worldwide_office_id: worldwide_office

    assert_response :success
    assert_template :edit
    assert_equal worldwide_office, assigns(:accessible)
    assert assigns(:access_and_opening_times).is_a?(AccessAndOpeningTimes)
    assert assigns(:access_and_opening_times).new_record?
    assert_nil assigns(:access_and_opening_times).body
    assert_equal worldwide_office, assigns(:access_and_opening_times).accessible
  end

  test "GET on :edit sets the default body for an office if a default is available" do
    worldwide_organisation = create(:worldwide_organisation)
    access_and_opening_times = create(:access_and_opening_times, accessible: worldwide_organisation, body: 'default from org')
    worldwide_office = create(:worldwide_office, worldwide_organisation: worldwide_organisation)
    get :edit, worldwide_organisation_id: worldwide_organisation, worldwide_office_id: worldwide_office

    assert_response :success
    assert_equal worldwide_office, assigns(:accessible)
    assert assigns(:access_and_opening_times).new_record?
    assert_equal 'default from org', assigns(:access_and_opening_times).body
    assert_equal worldwide_office, assigns(:access_and_opening_times).accessible
  end

  test "GET on :edit builds an access and opening times instance for the office, even when the org already has one" do
    worldwide_organisation = create(:worldwide_organisation)
    access_and_opening_times = create(:access_and_opening_times, accessible: worldwide_organisation)
    worldwide_office = create(:worldwide_office, worldwide_organisation: worldwide_organisation)
    get :edit, worldwide_organisation_id: worldwide_organisation, worldwide_office_id: worldwide_office

    assert_response :success
    assert_template :edit
    assert_equal worldwide_office, assigns(:accessible)
    assert assigns(:access_and_opening_times).is_a?(AccessAndOpeningTimes)
    assert assigns(:access_and_opening_times).new_record?
    assert_equal worldwide_office, assigns(:access_and_opening_times).accessible
  end

  test "POST on :create saves the access and opening times details to the organisation" do
    worldwide_organisation = create(:worldwide_organisation)
    post :create, worldwide_organisation_id: worldwide_organisation, access_and_opening_times: { body: 'body text' }

    assert access_and_opening_times = worldwide_organisation.access_and_opening_times
    assert_equal 'body text', access_and_opening_times.body
    assert_redirected_to access_info_admin_worldwide_organisation_path(worldwide_organisation)
  end

  test "POST on :create saves access info to an office and redirects to the offices page for the organisation" do
    worldwide_organisation = create(:worldwide_organisation)
    worldwide_office = create(:worldwide_office, worldwide_organisation: worldwide_organisation)
    post :create, worldwide_organisation_id: worldwide_organisation, worldwide_office_id: worldwide_office, access_and_opening_times: { body: 'custom body text' }

    assert access_and_opening_times = worldwide_office.access_and_opening_times
    assert_equal 'custom body text', access_and_opening_times.body
    assert_redirected_to admin_worldwide_organisation_worldwide_offices_path(worldwide_organisation)
  end

  view_test "POST on :create displays errors if access and opening times info is invalid" do
    worldwide_organisation = create(:worldwide_organisation)
    post :create, worldwide_organisation_id: worldwide_organisation, access_and_opening_times: { body: '' }

    assert_nil worldwide_organisation.access_and_opening_times
    assert_template :edit
    assert_select "form" do
      assert_select ".field_with_errors textarea[name=?]", "access_and_opening_times[body]"
    end
  end

  test 'PUT on :update updates the access and opening times details' do
    worldwide_organisation = create(:worldwide_organisation)
    access_and_opening_times = create(:access_and_opening_times, accessible: worldwide_organisation)
    put :update, worldwide_organisation_id: worldwide_organisation, access_and_opening_times: { body: 'new body' }

    assert_equal 'new body', access_and_opening_times.reload.body
    assert_redirected_to access_info_admin_worldwide_organisation_path(worldwide_organisation)
  end

  test "PUT on :update updates an offices access information and not the organisation" do
    worldwide_organisation = create(:worldwide_organisation)
    worldwide_office = create(:worldwide_office, worldwide_organisation: worldwide_organisation)
    default_access_and_opening_times = create(:access_and_opening_times, accessible: worldwide_organisation, body: 'default body')
    access_and_opening_times = create(:access_and_opening_times, accessible: worldwide_office)
    put :update, worldwide_organisation_id: worldwide_organisation, worldwide_office_id: worldwide_office, access_and_opening_times: { body: 'custom new body' }

    assert_equal 'custom new body', access_and_opening_times.reload.body
    assert_equal 'default body', default_access_and_opening_times.body
    assert_redirected_to admin_worldwide_organisation_worldwide_offices_path(worldwide_organisation)
  end

  view_test "PUT on :update displays errors if access and opening times info is invalid" do
    worldwide_organisation = create(:worldwide_organisation)
    access_and_opening_times = create(:access_and_opening_times, accessible: worldwide_organisation, body: 'old body')
    put :update, worldwide_organisation_id: worldwide_organisation, access_and_opening_times: { body: '' }

    assert_equal 'old body', access_and_opening_times.reload.body
    assert_template :edit
    assert_select "form" do
      assert_select ".field_with_errors textarea[name=?]", "access_and_opening_times[body]"
    end
  end

  test 'the office is loaded scoped to the organisation to avoid slug clashes' do
    worldwide_organisation = create(:worldwide_organisation)
    office_for_other_org = create(:worldwide_office)

    assert_raise ActiveRecord::RecordNotFound do
      get :edit, worldwide_organisation_id: worldwide_organisation, worldwide_office_id: office_for_other_org
    end

    assert_raise ActiveRecord::RecordNotFound do
      post :create, worldwide_organisation_id: worldwide_organisation, worldwide_office_id: office_for_other_org, access_and_opening_times: { body: 'body' }
    end

    assert_raise ActiveRecord::RecordNotFound do
      put :update, worldwide_organisation_id: worldwide_organisation, worldwide_office_id: office_for_other_org, access_and_opening_times: { body: 'body' }
    end
  end
end
