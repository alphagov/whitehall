require 'test_helper'

class Admin::GenericEditionsController::UnpublishingTest < ActionController::TestCase
  tests Admin::GenericEditionsController

  setup { login_as :managing_editor }

  view_test "displays unpublish button for unpublishable editions" do
    edition = create(:published_edition)
    get :show, params: { id: edition }

    assert_select "a", text: "Withdraw or unpublish"
  end

  view_test "does not display unpublish button if edition is not unpublishable" do
    login_as :managing_editor
    edition = create(:draft_edition)
    get :show, params: { id: edition }

    refute_select "a", text: "Withdraw or unpublish"
  end
end
