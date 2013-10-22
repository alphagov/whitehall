require 'test_helper'

class Admin::GenericEditionsController::ForcePublishingDocumentsTest < ActionController::TestCase
  tests Admin::GenericEditionsController

  view_test "should not display the force publish form if edition is publishable" do
    login_as :departmental_editor
    edition = create(:submitted_edition)
    get :show, id: edition
    refute_select force_publish_button_selector(edition)
  end

  view_test "should display the force publish form if edition is not publishable but is force-publishable" do
    login_as :departmental_editor
    edition = create(:draft_edition)
    get :show, id: edition
    assert_select force_publish_button_selector(edition), count: 1
  end

  view_test "should not display the force publish form if edition is neither publishable nor force-publishable" do
    login_as :policy_writer
    edition = create(:draft_edition)
    get :show, id: edition
    refute_select force_publish_button_selector(edition)
  end

  view_test "show should indicate a force-published document" do
    login_as :policy_writer
    edition = create(:published_edition, force_published: true)
    get :show, id: edition
    assert_select ".force_published"
  end

  view_test "show should not display the approve_retrospectively form for the creator" do
    creator = create(:departmental_editor, name: "Fred")
    login_as(creator)
    edition = create(:published_edition, force_published: true, creator: creator)
    get :show, id: edition
    refute_select ".force_published form input"
  end

  view_test "show should display the approve_retrospectively form for a departmental editor who wasn't the creator" do
    creator = create(:departmental_editor, name: "Fred")
    login_as(creator)
    edition = create(:published_edition, force_published: true, creator: creator)
    login_as(create(:departmental_editor, name: "Another Editor"))
    get :show, id: edition
    assert_select ".force_published form input"
  end
end
