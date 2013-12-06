require 'test_helper'

class TakePartPagesControllerTest < ActionController::TestCase
  should_be_a_public_facing_controller

  view_test "GET show renders the take part page" do
    take_part_page = create(:take_part_page)

    get :show, id: take_part_page

    assert_response :success
    assert_select 'h1', text: take_part_page.title
  end
end
