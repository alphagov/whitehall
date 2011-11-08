require 'test_helper'

class Admin::PreviewControllerTest < ActionController::TestCase
  setup do
    @user = login_as :policy_writer
  end

  test_controller_is_a Admin::BaseController

  test "renders the body param using govspeak into a document body template" do
    post :preview, body: "# gov speak"
    assert_select "section.document_view .body h1", "gov speak"
  end
end