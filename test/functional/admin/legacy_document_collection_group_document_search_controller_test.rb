require "test_helper"

class Admin::LegacyDocumentCollectionGroupDocumentSearchControllerTest < ActionController::TestCase
  tests Admin::DocumentCollectionGroupDocumentSearchController

  setup do
    @collection = create(:document_collection, :with_group)
    @group = @collection.groups.first
    @request_params = { document_collection_id: @collection, group_id: @group }
    login_as create(:writer)
  end

  test "GET #search_options blocks out users with no permissions" do
    get :search_options, params: @request_params
    assert_template :forbidden
  end

  test "POST #search blocks out users with no permissions" do
    post :search, params: @request_params
    assert_template :forbidden
  end

  test "GET #search_title_slug blocks out users with no permissions" do
    get :search_title_slug, params: @request_params
    assert_template :forbidden
  end
end
