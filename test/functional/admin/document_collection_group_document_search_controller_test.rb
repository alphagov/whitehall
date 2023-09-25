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

  view_test "POST #search with an empty option shows an alert flash" do
    @request_params[:search_option] = ""
    post :search, params: @request_params
    assert_template "document_collection_group_document_search/search_options"
    assert_select ".gem-c-error-alert__message", text: /Please select a search option/
  end

  view_test "POST #search with no search options shows an alert flash" do
    post :search, params: @request_params
    assert_template "document_collection_group_document_search/search_options"
    assert_select ".gem-c-error-alert__message", text: /Please select a search option/
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

  test "GET #search_title_slug without query renders search for title & slug page with no results section" do
    get :search_title_slug, params: @request_params
    assert_template "document_collection_group_document_search/search_title_slug"
    assert_select ".app-view-document-collection-document-search-results", count: 0
  end

  view_test "GET #search_title_slug with a query returns the document with the query in the results" do
    edition = build(:consultation, title: "Something", document: build(:document, slug: "something"))

    mock_live_editions = mock
    mock_live_editions.expects(:with_title_containing).with("Something").once.returns([edition])

    Edition.expects(:published).once.returns(mock_live_editions)

    @request_params[:query] = "Something "
    get :search_title_slug, params: @request_params

    assert_template "document_collection_group_document_search/search_title_slug"
    assert_select ".govuk-table__row .govuk-table__cell a[href='#{edition.public_url}']", text: "View #{edition.title}"
  end

  view_test "GET #search_title_slug with a query that returns no results renders empty results list" do
    mock_live_editions = mock
    mock_live_editions.expects(:with_title_containing).with("Something").once.returns([])
    Edition.expects(:published).once.returns(mock_live_editions)

    @request_params[:query] = "Something "
    get :search_title_slug, params: @request_params
    assert_template "document_collection_group_document_search/search_title_slug"
    assert_select ".govuk-body", text: /No documents found/
  end

  view_test "GET #search_title_slug with an empty query string shows an alert flash" do
    @request_params[:query] = ""
    get :search_title_slug, params: @request_params
    assert_template "document_collection_group_document_search/search_title_slug"
    assert_select ".gem-c-error-alert__message", text: /Please enter a search query/
  end
end
