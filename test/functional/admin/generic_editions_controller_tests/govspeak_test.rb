require 'test_helper'

class Admin::GenericEditionsController::GovspeakTest < ActionController::TestCase
  tests Admin::GenericEditionsController

  setup do
    login_as :policy_writer
  end

  view_test "should render the content using govspeak markup" do
    draft_edition = create(:draft_edition, body: "body-in-govspeak")
    govspeak_transformation_fixture default: "\n", "body-in-govspeak" => "body-in-html" do
      get :show, id: draft_edition
    end

    assert_select ".body", text: "body-in-html"
  end
end