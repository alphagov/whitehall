require "test_helper"

class Admin::DocumentCollectionGroupDocumentSearchControllerTest < ActionController::TestCase
  setup do
    @collection = create(:document_collection, :with_group)
    @group = @collection.groups.first
    @request_params = { document_collection_id: @collection, group_id: @group }
    @default_filter_params = {
      state: "active",
      per_page: 15,
    }
    @user = login_as :gds_editor
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
    assert_template "document_collection_group_document_search/search_options"
  end

  test "POST #search redirects to #add_by_title if search option passed is title" do
    @request_params[:search_option] = "title"
    post :search, params: @request_params
    assert_redirected_to admin_document_collection_group_add_by_title_path(@collection, @group)
  end

  test "POST #search redirects to #add_by_url if search option passed is url" do
    @request_params[:search_option] = "url"
    post :search, params: @request_params
    assert_redirected_to admin_document_collection_group_add_by_url_path(@collection, @group)
  end

  test "GET #add_by_title without query renders search for title page with no results section" do
    get :add_by_title, params: @request_params

    assert_template "document_collection_group_document_search/add_by_title"
    assert_select ".app-view-document-collection-document-search-results", count: 0
  end

  view_test "GET #add_by_title with a query that returns no results renders message to redirect to #add_by_url" do
    @request_params[:title] = "Something "

    get :add_by_title, params: @request_params
    assert_template "document_collection_group_document_search/add_by_title"
    assert_select ".govuk-body", text: /No results found. Search again using the full URL./
    assert_select ".govuk-body .govuk-link[href='/government/admin/collections/#{@collection.id}/groups/#{@group.id}/add_by_url']", text: "full URL"
  end

  view_test "GET #add_by_title with an empty query string shows an alert flash" do
    @request_params[:title] = ""
    get :add_by_title, params: @request_params
    assert_template "document_collection_group_document_search/add_by_title"
    assert_select ".gem-c-error-alert__message", text: /Please enter a search query/
  end

  view_test "GET #add_by_url should render add_by_url page" do
    get :add_by_url, params: @request_params
    assert_template "document_collection_group_document_search/add_by_url"
  end

  view_test "GET :add_by_title with search value renders paginated results" do
    16.times { create(:published_edition, title: "Something") }
    @request_params[:title] = "Something "

    get :add_by_title, params: @request_params
    assert_response :success
    assert_template "document_collection_group_document_search/add_by_title"
    assert_select "input[name='title']"
    assert_select ".govuk-heading-s", "16 documents"
    assert_select ".govuk-table tr", count: 15
    assert_select "nav.govuk-pagination"
  end

  view_test "GET :add_by_title with search value renders results without pagination if length of result is 15" do
    15.times { create(:published_edition, title: "Something") }
    @request_params[:title] = "Something "

    get :add_by_title, params: @request_params
    assert_response :success
    assert_template "document_collection_group_document_search/add_by_title"
    assert_select "input[name='title']"
    assert_select ".govuk-heading-s", "15 documents"
    assert_select ".govuk-table tr", count: 15
    assert_select "nav.govuk-pagination", count: 0
  end

  view_test "GET :add_by_title with search value only returns published editions" do
    create(:published_edition, title: "Something published")
    create(:edition, title: "Something unpublished")
    @request_params[:title] = "Something "

    get :add_by_title, params: @request_params
    assert_select ".govuk-heading-s", "1 document"
    assert_select ".govuk-table tr", text: /Something published/
  end
end
