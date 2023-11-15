require "test_helper"

class Admin::DocumentCollectionGroupMembershipsControllerTest < ActionController::TestCase
  setup do
    @collection = create(:document_collection, :with_group)
    @group = @collection.groups.first
    login_as :writer
  end

  should_be_an_admin_controller

  def id_params
    { document_collection_id: @collection, group_id: @group }
  end

  view_test "GET #index renders a link to add a document and informs the user there are no documents in the group if none are present" do
    document_add_search_options_path = admin_document_collection_group_search_options_path(@collection, @group)
    get :index, params: { document_collection_id: @collection, group_id: @group }

    assert_select ".govuk-link[href='#{document_add_search_options_path}']", text: "Add document"
    assert_select ".govuk-warning-text__text", text: /There are no documents inside this group/
  end

  view_test "GET #index renders a link to add a document and a table of memberships with view and delete links" do
    document = create(:document)
    edition = create(:edition, document:)
    whitehall_membership = create(:document_collection_group_membership, document:)
    whitehall_confirm_destroy_path = confirm_destroy_admin_document_collection_group_document_collection_group_membership_path(@collection, @group, whitehall_membership)

    non_whitehall_link = create(:document_collection_non_whitehall_link, title: "Non Whitehall")
    non_whitehall_membership = create(:document_collection_group_membership, non_whitehall_link:, document: nil)
    non_whitehall_confirm_destroy_path = confirm_destroy_admin_document_collection_group_document_collection_group_membership_path(@collection, @group, non_whitehall_membership)

    document_add_search_options_path = admin_document_collection_group_search_options_path(@collection, @group)

    @group.memberships << whitehall_membership
    @group.memberships << non_whitehall_membership

    get :index, params: { document_collection_id: @collection, group_id: @group }

    assert_select ".govuk-link[href='#{document_add_search_options_path}']", text: "Add document"
    assert_select ".govuk-table__row:nth-child(1) .govuk-table__cell:nth-child(2) a[href='#{edition.public_url}']", text: "View #{edition.title}"
    assert_select ".govuk-table__row:nth-child(1) .govuk-table__cell:nth-child(2) a[href='#{whitehall_confirm_destroy_path}']", text: "Remove #{edition.title}"
    assert_select ".govuk-table__row:nth-child(2) .govuk-table__cell:nth-child(2) a[href='#{Plek.website_root + non_whitehall_link.base_path}']", text: "View #{non_whitehall_link.title}"
    assert_select ".govuk-table__row:nth-child(2) .govuk-table__cell:nth-child(2) a[href='#{non_whitehall_confirm_destroy_path}']", text: "Remove #{non_whitehall_link.title}"
  end

  test "POST #create_whitehall_member adds a whitehall document to a group and redirects" do
    document = create(:publication).document
    assert_difference "@group.reload.documents.size" do
      post :create_whitehall_member, params: id_params.merge(document_id: document.id)
    end
    assert_redirected_to admin_document_collection_group_document_collection_group_memberships_path(@collection, @group)
  end

  test "POST #create_whitehall_member warns user when document not found" do
    post :create_whitehall_member, params: id_params.merge(document_id: 1234, title: "blah")
    assert_match %r{couldn't find.*blah}, flash[:alert]
  end

  view_test "GET #reorder should be able to visit reorder document page" do
    document = create(:document)
    create(:edition, document:)
    non_whitehall_link = create(:document_collection_non_whitehall_link)
    @collection = create(:document_collection, :with_group)
    @group = @collection.groups.first
    @group.memberships << @member_1 = create(:document_collection_group_membership, document:)
    @group.memberships << @member_2 = create(:document_collection_group_membership, non_whitehall_link:, document: nil)

    get :reorder, params: { document_collection_id: @collection, group_id: @group }

    assert_response :success
    assert_select "h1", /Reorder documents/
  end

  view_test "GET #confirm_destroy renders deletion confirmation for whitehall document collection group member" do
    document = create(:document)
    create(:edition, document:, title: "Document")
    @collection = create(:document_collection, :with_group)
    @group = @collection.groups.first
    @group.memberships << @member = create(:document_collection_group_membership, document:)

    get :confirm_destroy, params: { document_collection_id: @collection, group_id: @group, id: @member }

    assert_response :success
    assert_select "h1", /Remove document/
    assert_select "p", /Are you sure you want to remove "Document" from this collection?/
  end

  view_test "GET #confirm_destroy renders deletion confirmation for non-whitehall document collection group member" do
    non_whitehall_link = create(:document_collection_non_whitehall_link, title: "Document")
    @collection = create(:document_collection, :with_group)
    @group = @collection.groups.first
    @group.memberships << @member = create(:document_collection_group_membership, non_whitehall_link:, document: nil)

    get :confirm_destroy, params: { document_collection_id: @collection, group_id: @group, id: @member }

    assert_response :success
    assert_select "h1", /Remove document/
    assert_select "p", /Are you sure you want to remove "Document" from this collection?/
  end

  test "POST #create_member_by_govuk_url warns user when url is not from gov.uk" do
    DocumentCollectionNonWhitehallLink::GovukUrl.any_instance
      .stubs(:save).returns(nil)
    ActiveModel::Errors.any_instance
      .expects(:full_messages).once.returns(["Url must be a valid GOV.UK URL"])
    post :create_member_by_govuk_url, params: id_params.merge(document_url: "https://not-a-gov-uk-url")
    assert_match "Url must be a valid GOV.UK URL.", flash[:alert]
  end

  test "POST #create_member_by_govuk_url redirects back to add by URL page when url is not from gov.uk" do
    DocumentCollectionNonWhitehallLink::GovukUrl.any_instance
      .stubs(:save).returns(nil)
    post :create_member_by_govuk_url, params: id_params.merge(document_url: "https://not-a-gov-uk-url")
    assert_redirected_to admin_document_collection_group_add_by_url_path(@collection, @group)
  end

  test "POST #create_member_by_govuk_url redirects to add by URL page when url is not from gov.uk" do
    title = "My test title"
    url = "https://a-gov-uk-url"
    govuk_url_mock = mock
    govuk_url_mock.stubs(:title).returns(title)
    DocumentCollectionNonWhitehallLink::GovukUrl.expects(:new).with(
      url:,
      document_collection_group: @group,
    ).returns(govuk_url_mock)
    govuk_url_mock.expects(:save).once.returns(true)
    post :create_member_by_govuk_url, params: id_params.merge(document_url: url)
    assert_redirected_to admin_document_collection_group_document_collection_group_memberships_path(@collection, @group),
                         notice: "'#{title}' added to '#{@group.heading}'"
  end

  view_test "GET #index should render 'unavailable documents' and notification" do
    document = create(:document, latest_edition: nil)
    whitehall_membership = create(:document_collection_group_membership, document:)
    whitehall_confirm_destroy_path = confirm_destroy_admin_document_collection_group_document_collection_group_membership_path(@collection, @group, whitehall_membership)

    @group.memberships << whitehall_membership

    get :index, params: { document_collection_id: @collection, group_id: @group }

    assert_select ".govuk-table__row", { count: 0, text: "View Unavailable Document" }
    assert_select ".govuk-table__row", text: /Remove Unavailable Document/
    assert_select ".govuk-table__row", a: whitehall_confirm_destroy_path
    assert_select ".govuk-notification-banner__heading", text: "Remove 1 unavailable document within the group."
  end

  view_test "GET #reorder should render 'unavailable documents'" do
    document = create(:document, latest_edition: nil)
    whitehall_membership = create(:document_collection_group_membership, document:)
    @group.memberships << whitehall_membership
    get :reorder, params: { document_collection_id: @collection, group_id: @group }

    assert_response :success
    assert_select "h1", /Reorder documents/
    assert_select ".gem-c-reorderable-list__title", text: "Unavailable Document"
  end

  view_test "GET #confirm_destroy should render 'unavailable documents'" do
    document = create(:document, latest_edition: nil)
    whitehall_membership = create(:document_collection_group_membership, document:)
    @group.memberships << whitehall_membership

    get :confirm_destroy, params: { document_collection_id: @collection, group_id: @group, id: whitehall_membership }

    assert_response :success
    assert_select "h1", /Remove document/
    assert_select "p", /Are you sure you want to remove "Unavailable Document" from this collection?/
  end
end
