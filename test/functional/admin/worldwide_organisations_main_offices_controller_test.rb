require "test_helper"

class Admin::WorldwideOrganisationsMainOfficesControllerTest < ActionController::TestCase
  setup do
    login_as :gds_admin
  end

  should_be_an_admin_controller

  test "GET :choose_main_office calls correctly" do
    organisation = create(:editionable_worldwide_organisation)

    get :show, params: { id: organisation.id }

    assert_response :success
    assert_equal organisation, assigns(:worldwide_organisation)
  end

  view_test "GET :choose_main_office uses radios when 5 or less offices exist" do
    organisation = create(:editionable_worldwide_organisation)
    5.times { create(:worldwide_office, edition: organisation) }

    get :show, params: { id: organisation.id }

    assert_select ".govuk-radios"
    refute_select "select#worldwide_organisation_main_office_id"
  end

  view_test "GET :choose_main_office uses a select when 6 or more offices exist" do
    organisation = create(:editionable_worldwide_organisation)
    6.times { create(:worldwide_office, edition: organisation) }

    get :show, params: { id: organisation.id }

    assert_select "select#worldwide_organisation_main_office_id"
    refute_select ".govuk-radios"
  end

  test "setting the main office" do
    offices = [create(:worldwide_office), create(:worldwide_office)]
    worldwide_organisation = create(:editionable_worldwide_organisation, offices:)

    put :update, params: { id: worldwide_organisation.id, worldwide_organisation: { main_office_id: offices.last.id } }

    assert_equal offices.last, worldwide_organisation.reload.main_office
    assert_equal "Main office updated successfully", flash[:notice]
    assert_redirected_to admin_worldwide_organisation_worldwide_offices_path(worldwide_organisation)
  end
end
