require 'test_helper'

class WorldwideOfficesControllerTest < ActionController::TestCase
  setup do
    @worldwide_office = create(:worldwide_office)
  end

  test "get #show loads the office and renders the show template" do
    get :show, worldwide_organisation_id: @worldwide_office.worldwide_organisation_id, id: @worldwide_office

    assert_response :success
    assert_template :show
    assert_equal @worldwide_office, assigns(:worldwide_office)
    assert_equal @worldwide_office.worldwide_organisation, assigns(:worldwide_organisation)
  end

  test "does not load offices from other organisation as there may be slug clashes" do
    assert_raise ActiveRecord::RecordNotFound do
      get :show, worldwide_organisation_id: create(:worldwide_organisation), id: @worldwide_office
    end
  end
end
