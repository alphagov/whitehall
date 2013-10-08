require 'test_helper'

class Admin::GenericEditionsController::PublishingDocumentsTest < ActionController::TestCase
  tests Admin::GenericEditionsController

  setup do
    login_as :departmental_editor
  end

  view_test "should display the publish form if edition is publishable" do
    edition = create(:submitted_edition)
    get :show, id: edition
    assert_select publish_form_selector(edition), count: 1
  end

  view_test "should not display the publish form if edition is not publishable" do
    edition = create(:draft_edition)
    get :show, id: edition
    refute_select publish_form_selector(edition)
  end
end
