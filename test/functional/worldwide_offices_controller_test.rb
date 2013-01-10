require "test_helper"

class WorldwideOfficesControllerTest < ActionController::TestCase
  include ActionDispatch::Routing::UrlFor
  include PublicDocumentRoutesHelper

  should_be_a_public_facing_controller

  test "shows worldwide office information" do
    office = create(:worldwide_office)
    get :show, id: office.id
    assert_equal office, assigns(:worldwide_office)
  end
end
