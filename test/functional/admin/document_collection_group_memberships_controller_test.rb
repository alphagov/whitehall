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

  test "POST #create_whitehall_member adds a whitehall document to a group and redirects" do
    document = create(:publication).document
    assert_difference "@group.reload.documents.size" do
      post :create_whitehall_member, params: id_params.merge(document_id: document.id)
    end
    assert_redirected_to admin_document_collection_groups_path(@collection)
  end

  test "POST #create_whitehall_member warns user when document not found" do
    post :create_whitehall_member, params: id_params.merge(document_id: 1234, title: "blah")
    assert_match %r{couldn't find.*blah}, flash[:alert]
  end

  test "POST #create_non_whitehall_member adds a non-whitehall document to a group and redirects" do
    stub_publishing_api_has_lookups("/government/news/test" => "51ac4247-fd92-470a-a207-6b852a97f2db")
    res = stub_publishing_api_has_item(
      content_id: "51ac4247-fd92-470a-a207-6b852a97f2db",
      base_path: "/government/news/test",
      publishing_app: "content-publisher",
      title: "Lots of news",
    )

    assert_difference "@group.reload.non_whitehall_links.size" do
      post :create_non_whitehall_member, params: id_params.merge(url: "https://www.gov.uk/government/news/test")
    end
    response = JSON.parse(res.response.body)

    assert_match "'#{response['title']}' added to '#{@group.heading}'", flash[:notice]
    assert_redirected_to admin_document_collection_groups_path(@collection)
  end

  test "POST #create_non_whitehall_member warns user when url is not from gov.uk" do
    post :create_non_whitehall_member, params: id_params.merge(url: "https://www.peters-animals.com")
    assert_match "Url must be a valid GOV.UK URL.", flash[:alert]
  end

  test "POST #create_non_whitehall_member warns user when url is invalid" do
    post :create_non_whitehall_member, params: id_params.merge(url: "https://wwww.too-many-dubs.com")
    assert_match "Url must be a valid GOV.UK URL", flash[:alert]
  end

  def remove_params
    id_params.merge(commit: "Remove")
  end

  def move_params
    id_params.merge(commit: "Move")
  end

  view_test "GET #index renders a link to add a document and informs the user there are no documents in the group if none are present" do
    get :index, params: { document_collection_id: @collection, group_id: @group }

    assert_select ".govuk-link[href='#']", text: "Add document"
    assert_select ".govuk-warning-text__text", text: /There are no documents inside this group/
  end

  view_test "GET #index renders a link to add a document and a table of memberships with view and delete links" do
    document = create(:document)
    edition = create(:edition, document:)
    membership = create(:document_collection_group_membership, document:)

    @group.memberships << membership

    get :index, params: { document_collection_id: @collection, group_id: @group }

    assert_select ".govuk-link[href='#']", text: "Add document"
    assert_select ".govuk-table__row:nth-child(1) .govuk-table__cell:nth-child(2) a[href='#{edition.public_url}']", text: "View"
    assert_select ".govuk-table__row:nth-child(1) .govuk-table__cell:nth-child(2) a[href='#']", text: "Delete"
  end

  view_test "DELETE #destroy removes memberships and redirects when Remove clicked" do
    memberships = [create(:document_collection_group_membership),
                   create(:document_collection_group_membership)]
    @group.memberships << memberships
    assert_difference "@group.reload.memberships.size", -1 do
      delete :destroy, params: remove_params.merge(memberships: [memberships.first.id])
    end
    assert_redirected_to admin_document_collection_groups_path(@collection)
    assert_match %r{1 document removed}, flash[:notice]
  end

  test "DELETE #destroy sets flash message if no documents selected" do
    delete :destroy, params: remove_params
    assert_match %r{select one or more documents}i, flash[:alert]
  end

  test "DELETE #destroy moves documents and redirects when Move clicked" do
    memberships = [create(:document_collection_group_membership),
                   create(:document_collection_group_membership)]
    @group.memberships << memberships
    new_group = build(:document_collection_group)
    @collection.groups << new_group
    assert_difference "new_group.reload.memberships.size", 1 do
      assert_difference "@group.reload.memberships.size", -1 do
        delete :destroy,
               params: move_params.merge(
                 memberships: [memberships.first.id],
                 new_group_id: new_group.id,
               )
      end
    end
    assert_redirected_to admin_document_collection_groups_path(@collection)
    assert_match %r{1 document moved to '#{new_group.heading}'}, flash[:notice]
  end
end
