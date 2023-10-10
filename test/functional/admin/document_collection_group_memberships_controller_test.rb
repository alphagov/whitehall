require "test_helper"

class Admin::DocumentCollectionGroupMembershipsControllerTest < ActionController::TestCase
  setup do
    @collection = create(:document_collection, :with_group)
    @group = @collection.groups.first
    login_as_preview_design_system_user :writer
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
    membership = create(:document_collection_group_membership, document:)
    confirm_destroy_path = confirm_destroy_admin_document_collection_group_document_collection_group_membership_path(@collection, @group, membership)
    document_add_search_options_path = admin_document_collection_group_search_options_path(@collection, @group)

    @group.memberships << membership

    get :index, params: { document_collection_id: @collection, group_id: @group }

    assert_select ".govuk-link[href='#{document_add_search_options_path}']", text: "Add document"
    assert_select ".govuk-table__row:nth-child(1) .govuk-table__cell:nth-child(2) a[href='#{edition.public_url}']", text: "View #{edition.title}"
    assert_select ".govuk-table__row:nth-child(1) .govuk-table__cell:nth-child(2) a[href='#{confirm_destroy_path}']", text: "Remove #{edition.title}"
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

  view_test "GET :should be able to visit reorder document page" do
    document = create(:document)
    create(:edition, document:)
    @collection = create(:document_collection, :with_group)
    @group = @collection.groups.first
    @group.memberships << @member_1 = create(:document_collection_group_membership, document:)
    @group.memberships << @member_2 = create(:document_collection_group_membership, document:)

    get :reorder, params: { document_collection_id: @collection, group_id: @group }
    assert_response :success
    assert_select "h1", /Reorder documents/
  end
end
