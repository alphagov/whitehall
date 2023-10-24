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
    @user = login_as_preview_design_system_user :gds_editor
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

  test "GET #add_by_title without query renders search for title  page with no results section" do
    get :add_by_title, params: @request_params

    assert_template "document_collection_group_document_search/add_by_title"
    assert_select ".app-view-document-collection-document-search-results", count: 0
  end

  test "GET :add_by_title with search value passes title and default params to filter" do
    stub_filter = stub_edition_filter({ editions: [], options: { per_page: 15 } })
    edition_scope = Edition.with_translations(I18n.locale)
    default_filter_params_with_title = @default_filter_params.merge(title: "Something")
    @request_params[:title] = "Something"
    Admin::EditionFilter.expects(:new).with(edition_scope, @user, default_filter_params_with_title).returns(stub_filter)

    get :add_by_title, params: @request_params
    assert_template "document_collection_group_document_search/add_by_title"
  end

  view_test "GET #add_by_title with a query that returns no results renders empty results list" do
    editions = []
    stub_filter = stub_edition_filter({ editions:, options: { per_page: 15 } })
    Admin::EditionFilter.stubs(:new).returns(stub_filter)
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
    editions = []
    edition = build(:news_article, title: "Something", document: build(:document, slug: "something"))
    16.times { editions << edition }

    stub_filter = stub_edition_filter({ editions:, options: { per_page: 15 } })
    Admin::EditionFilter.stubs(:new).returns(stub_filter)
    @request_params[:title] = "Something "

    get :add_by_title, params: @request_params
    assert_response :success
    assert_template "document_collection_group_document_search/add_by_title"
    assert_select "input[name='title']"
    assert_select ".govuk-heading-s", "16 documents"
    assert_select ".govuk-table" do
      assert_select "tr", count: 15
    end
    assert_select "nav.govuk-pagination"
  end

  view_test "GET :add_by_title with search value renders results without pagination if length of result is 15" do
    editions = []
    edition = build(:news_article, title: "Something", document: build(:document, slug: "something"))
    15.times { editions << edition }

    stub_filter = stub_edition_filter({ editions:, options: { per_page: 15 } })
    Admin::EditionFilter.stubs(:new).returns(stub_filter)
    @request_params[:title] = "Something "

    get :add_by_title, params: @request_params
    assert_response :success
    assert_template "document_collection_group_document_search/add_by_title"
    assert_select "input[name='title']"
    assert_select ".govuk-heading-s", "15 documents"
    assert_select ".govuk-table" do
      assert_select "tr", count: 15
    end
    assert_select "nav.govuk-pagination", count: 0
  end

private

  def stub_edition_filter(attributes = {})
    default_attributes = {
      editions: Kaminari.paginate_array(attributes[:editions] || [], limit: attributes[:options][:per_page]).page(1),
      page_title: "",
      edition_state: "",
      valid?: true,
      options: {},
      hide_type: false,
    }
    stub("edition filter", default_attributes.merge(attributes.except(:editions)))
  end
end
