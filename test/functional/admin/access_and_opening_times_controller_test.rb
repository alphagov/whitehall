require 'test_helper'

class Admin::AccessAndOpeningTimesControllerTest < ActionController::TestCase
  setup do
    login_as :gds_editor
  end

  should_be_an_admin_controller

  test "GET on :new assigns a new access and opening times instance and renders the new template" do
    worldwide_organisation = create(:worldwide_organisation)
    get :new, worldwide_organisation_id: worldwide_organisation

    assert_response :success
    assert_template :new
    assert_equal worldwide_organisation, assigns(:accessible)
    assert assigns(:access_and_opening_times).is_a?(AccessAndOpeningTimes)
  end

  test "POST on :create saves the access and opening times details to the organisation" do
    worldwide_organisation = create(:worldwide_organisation)
    post :create, worldwide_organisation_id: worldwide_organisation, access_and_opening_times: { body: 'body text' }

    assert access_and_opening_times = worldwide_organisation.access_and_opening_times
    assert_equal 'body text', access_and_opening_times.body
    assert_redirected_to access_info_admin_worldwide_organisation_path(worldwide_organisation)
  end

  view_test "POST on :create displays errors if access and opening times info is invalid" do
    worldwide_organisation = create(:worldwide_organisation)
    post :create, worldwide_organisation_id: worldwide_organisation, access_and_opening_times: { body: '' }

    assert_nil worldwide_organisation.access_and_opening_times
    assert_template :new
    assert_select "form" do
      assert_select ".field_with_errors textarea[name=?]", "access_and_opening_times[body]"
    end
  end

  test "GET on :edit loads the access and opening times instance and renders the edit template" do
    worldwide_organisation = create(:worldwide_organisation)
    access_and_opening_times = create(:access_and_opening_times, accessible: worldwide_organisation)
    get :edit, worldwide_organisation_id: worldwide_organisation

    assert_response :success
    assert_template :edit
    assert_equal worldwide_organisation, assigns(:accessible)
    assert_equal access_and_opening_times, assigns(:access_and_opening_times)
  end

  test 'PUT on :update updates the access and opening times details' do
    worldwide_organisation = create(:worldwide_organisation)
    access_and_opening_times = create(:access_and_opening_times, accessible: worldwide_organisation)
    put :update, worldwide_organisation_id: worldwide_organisation, access_and_opening_times: { body: 'New body' }

    assert_equal 'New body', access_and_opening_times.reload.body
    assert_redirected_to access_info_admin_worldwide_organisation_path(worldwide_organisation)
  end

  view_test 'PUT on :update displays errors if access and opening times info is invalid' do
    worldwide_organisation = create(:worldwide_organisation)
    access_and_opening_times = create(:access_and_opening_times, accessible: worldwide_organisation, body: 'Old body')
    put :update, worldwide_organisation_id: worldwide_organisation, access_and_opening_times: { body: '' }

    assert_equal 'Old body', access_and_opening_times.reload.body
    assert_template :edit
    assert_select "form" do
      assert_select ".field_with_errors textarea[name=?]", "access_and_opening_times[body]"
    end
  end
end
