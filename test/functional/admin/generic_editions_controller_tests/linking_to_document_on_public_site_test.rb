require 'test_helper'

class Admin::GenericEditionsController::LinkingToDocumentOnPublicSiteTest < ActionController::TestCase
  include TaxonomyHelper
  tests Admin::GenericEditionsController

  setup do
    login_as :writer
  end

  view_test "should link to public version when published" do
    published_edition = create(:published_edition)
    stub_publishing_api_expanded_links_with_taxons(published_edition.content_id, [])

    get :show, params: { id: published_edition }
    assert_select link_to_public_version_selector, count: 1
  end

  view_test "should not link to public version when not published" do
    draft_edition = create(:draft_edition)
    stub_publishing_api_expanded_links_with_taxons(draft_edition.content_id, [])

    get :show, params: { id: draft_edition }
    refute_select link_to_public_version_selector
  end
end
