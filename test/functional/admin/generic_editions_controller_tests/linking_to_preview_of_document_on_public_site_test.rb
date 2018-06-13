require 'test_helper'

class Admin::GenericEditionsController::LinkingToPreviewOfDocumentOnPublicSiteTest < ActionController::TestCase
  include TaxonomyHelper
  tests Admin::GenericEditionsController

  setup do
    login_as :writer
  end

  view_test "should link to preview version when not published" do
    draft_edition = create(:draft_edition)
    stub_publishing_api_expanded_links_with_taxons(draft_edition.content_id, [])

    get :show, params: { id: draft_edition }
    assert_select link_to_preview_version_selector
  end
end
