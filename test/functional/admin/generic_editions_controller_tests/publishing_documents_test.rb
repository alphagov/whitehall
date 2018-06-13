require 'test_helper'

class Admin::GenericEditionsController::PublishingDocumentsTest < ActionController::TestCase
  include TaxonomyHelper
  tests Admin::GenericEditionsController

  setup do
    login_as :departmental_editor
  end

  view_test "should display the publish form if edition is publishable" do
    edition = create(:submitted_edition)
    stub_publishing_api_expanded_links_with_taxons(edition.content_id, [])

    get :show, params: { id: edition }
    assert_select publish_form_selector(edition), count: 1
  end

  view_test "should not display the publish form if edition is not publishable" do
    edition = create(:draft_edition)
    stub_publishing_api_expanded_links_with_taxons(edition.content_id, [])

    get :show, params: { id: edition }
    refute_select publish_form_selector(edition)
  end
end
