require "test_helper"

class Admin::DocumentCollectionGroupDocumentSearchControllerTest < ActionController::TestCase
  setup do
    @collection = create(:document_collection, :with_group)
    @group = @collection.groups.first
    @request_params = { document_collection_id: @collection, group_id: @group }
    login_as_preview_design_system_user :writer
  end

  should_be_an_admin_controller

  test "GET #search_options renders search options" do
    get :search_options, params: @request_params
    assert_template "document_collection_group_document_search/search_options"
  end

  test "POST #search is a noop when passed param is unrecognised" do
    @request_params[:search_option] = "non-existant"
    post :search, params: @request_params
    assert_template nil
  end

  test "POST #search redirects to #search_title_slug if search option passed is title-or-slug" do
    @request_params[:search_option] = "title-or-slug"
    post :search, params: @request_params
    assert_redirected_to admin_document_collection_group_search_title_slug_path(@collection, @group)
  end

  test "GET #search_title_slug renders search for title & slug" do
    get :search_title_slug, params: @request_params
    assert_template "document_collection_group_document_search/search_title_slug"
  end
end
