require "test_helper"

class Admin::DocumentCollectionEmailSubscriptionsControllerTest < ActionController::TestCase
  include TaxonomyHelper
  setup do
    login_as :writer
    @collection = create(:draft_document_collection, :with_group, taxonomy_topic_email_override: root_taxon_content_id)
    stub_publishing_api_has_item(content_id: root_taxon_content_id, title: root_taxon["title"])
    stub_taxonomy_with_all_taxons
  end

  should_be_an_admin_controller

  view_test "GET #edit renders successfully" do
    get :edit, params: { document_collection_id: @collection.id }
    assert_response :ok
    assert_select "div", /You cannot change the email notifications for this document collection/
  end
end
