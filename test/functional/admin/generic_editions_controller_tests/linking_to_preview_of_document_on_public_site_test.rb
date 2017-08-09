require 'test_helper'

class Admin::GenericEditionsController::LinkingToPreviewOfDocumentOnPublicSiteTest < ActionController::TestCase
  tests Admin::GenericEditionsController

  setup do
    login_as :writer
  end

  view_test "should link to preview version when not published" do
    draft_edition = create(:draft_edition)
    get :show, params: { id: draft_edition }
    assert_select link_to_preview_version_selector
  end
end
