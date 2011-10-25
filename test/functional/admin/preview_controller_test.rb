require 'test_helper'

class Admin::PreviewControllerTest < ActionController::TestCase
  setup do
    @user = login_as "George"
  end

  test 'is an admin controller' do
    assert @controller.is_a?(Admin::BaseController), "the controller should have the behaviour of an Admin::BaseController"
  end

  test "renders the body param using govspeak into a document body template" do
    post :preview, body: "# gov speak"
    assert_select "section.document_view .body h1", "gov speak"
  end
end