require "test_helper"

class Admin::DocumentCollectionGroupsControllerTest < ActionController::TestCase
  setup do
    @collection = create(:document_collection, :with_group)
    @group = @collection.groups.first
    login_as :writer
  end

  should_be_an_admin_controller

  view_test "GET #index lists the default group when no additional groups or memberships have been added" do
    get :index, params: { document_collection_id: @collection }

    assert_select "h1", text: "Document collections"
    assert_select ".govuk-summary-card__action a[href='#{new_admin_document_collection_group_path(@collection)}']", text: /Add group/
    assert_select ".govuk-summary-list__key", text: @group.heading
    assert_select ".govuk-summary-list__value", text: "0 documents in group"
    assert_select ".govuk-summary-list__actions a[href='#{admin_document_collection_group_document_collection_group_memberships_path(@collection, @group)}']", text: "View #{@group.heading}"
  end

  view_test "GET #index shows confirm delete links when 2 or more groups are present" do
    collection = create(:document_collection, :with_groups)
    group1 = collection.groups.first
    group2 = collection.groups.second

    publication = create(:publication)
    group1.documents = [publication.document]

    get :index, params: { document_collection_id: collection }

    assert_select ".govuk-summary-list__row:nth-child(1) .govuk-summary-list__key", text: group1.heading
    assert_select ".govuk-summary-list__row:nth-child(1) .govuk-summary-list__value", text: "1 document in group"
    assert_select ".govuk-summary-list__row:nth-child(1) .govuk-summary-list__actions a[href='#{admin_document_collection_group_document_collection_group_memberships_path(collection, group1)}']", text: "View #{group1.heading}"
    assert_select ".govuk-summary-list__row:nth-child(1) .govuk-summary-list__actions a[href='#{confirm_destroy_admin_document_collection_group_path(collection, group1)}']", text: "Delete #{group1.heading}"
    assert_select ".govuk-summary-list__row:nth-child(2) .govuk-summary-list__key", text: group2.heading
    assert_select ".govuk-summary-list__row:nth-child(2) .govuk-summary-list__value", text: "0 documents in group"
    assert_select ".govuk-summary-list__row:nth-child(2) .govuk-summary-list__actions a[href='#{admin_document_collection_group_document_collection_group_memberships_path(collection, group2)}']", text: "View #{group2.heading}"
    assert_select ".govuk-summary-list__row:nth-child(2) .govuk-summary-list__actions a[href='#{confirm_destroy_admin_document_collection_group_path(collection, group2)}']", text: "Delete #{group2.heading}"
  end

  view_test "GET #show assigns the correct attributes and renders successfully" do
    get :show, params: { document_collection_id: @collection, id: @group }
    assert_response :ok
    assert_equal @collection, assigns(:collection)
    assert_equal @group, assigns(:group)
  end

  view_test "GET #new renders successfully" do
    get :new, params: { document_collection_id: @collection }
    assert_response :ok
  end

  def post_create(params = {})
    params.reverse_merge!(heading: "Heading", body: "")
    post :create, params: { document_collection_id: @collection, document_collection_group: params }
  end

  test "POST #create creates a new group from valid data and redirects" do
    PublishingApiDocumentRepublishingJob.expects(:perform_async).with(@collection.document_id, false).once
    assert_difference("@collection.groups.count") do
      post_create(heading: "New group", body: "Group body")
    end
    group = DocumentCollectionGroup.last
    assert_equal "New group", group.heading
    assert_equal "Group body", group.body
    assert_redirected_to admin_document_collection_groups_path(@collection)
  end

  view_test "POST #create prompts for missing data if new group invalid" do
    post_create(heading: "")
    assert_response :success
    assert_select ".govuk-error-summary", text: /Heading/
  end

  view_test "GET #edit renders successfully" do
    get :edit, params: { document_collection_id: @collection, id: @group }
    assert_response :ok
  end

  def put_update(params)
    put :update, params: { document_collection_id: @collection, id: @group, document_collection_group: params }
  end

  test "PUT #update modifies the group and redirects" do
    PublishingApiDocumentRepublishingJob.expects(:perform_async).with(@collection.document_id, false).once
    put_update(heading: "New heading", body: "New body")
    @group.reload
    assert_equal "New heading", @group.heading
    assert_equal "New body", @group.body
    assert_redirected_to admin_document_collection_groups_path(@collection)
  end

  view_test "PUT #update prompts for missing data if group invalid" do
    put_update(heading: "")
    assert_response :success
    assert_select ".govuk-error-summary", text: /Heading/
  end

  test "GET #confirm_destroy redirects to the index page if only 1 group" do
    get :confirm_destroy, params: { document_collection_id: @collection, id: @group }
    assert_redirected_to admin_document_collection_groups_path(@collection)
  end

  test "GET #confirm_destroy assigns the correct values" do
    @collection.groups << build(:document_collection_group)
    get :confirm_destroy, params: { document_collection_id: @collection, id: @group }
    assert_equal @collection, assigns(:collection)
    assert_equal @group, assigns(:group)
  end

  test "DELETE #destroy deletes group and redirects" do
    PublishingApiDocumentRepublishingJob.expects(:perform_async).with(@collection.document_id, false).once
    assert_difference "@collection.groups.count", -1 do
      delete :destroy, params: { document_collection_id: @collection, id: @group }
    end
    assert_redirected_to admin_document_collection_groups_path(@collection)
    assert_equal "Group has been deleted", flash[:notice]
  end

  view_test "GET #index renders for a published collection" do
    collection = create(:published_document_collection, :with_group)

    get :index, params: { document_collection_id: collection }

    assert_response :ok
  end

  test "GET #show renders for a published collection" do
    collection = create(:published_document_collection, :with_group)

    get :show, params: { document_collection_id: collection, id: collection.groups.first }

    assert_response :ok
  end

  test "GET #new redirects for a published collection" do
    collection = create(:published_document_collection, :with_group)

    get :new, params: { document_collection_id: collection }

    assert_redirected_to admin_document_collection_path(collection)
    assert_equal "You cannot modify a published Document collection", flash[:alert]
  end

  test "GET #edit redirects for a published collection" do
    collection = create(:published_document_collection, :with_group)

    get :edit, params: { document_collection_id: collection, id: collection.groups.first }

    assert_redirected_to admin_document_collection_path(collection)
  end

  test "GET #confirm_destroy redirects for a published collection" do
    collection = create(:published_document_collection, :with_groups)

    get :confirm_destroy, params: { document_collection_id: collection, id: collection.groups.first }

    assert_redirected_to admin_document_collection_path(collection)
  end

  test "GET #reorder redirects for a published collection" do
    collection = create(:published_document_collection, :with_groups)

    get :reorder, params: { document_collection_id: collection }

    assert_redirected_to admin_document_collection_path(collection)
  end

  test "POST #create does not create a group for a published collection" do
    collection = create(:published_document_collection, :with_group)
    PublishingApiDocumentRepublishingJob.expects(:perform_async).never

    assert_no_difference "collection.groups.count" do
      post :create, params: { document_collection_id: collection, document_collection_group: { heading: "Heading" } }
    end
    assert_redirected_to admin_document_collection_path(collection)
  end

  test "PUT #update does not change a group for a scheduled collection" do
    collection = create(:scheduled_document_collection, :with_group)
    group = collection.groups.first

    put :update, params: { document_collection_id: collection, id: group, document_collection_group: { heading: "New heading" } }

    assert_redirected_to admin_document_collection_path(collection)
    assert_not_equal "New heading", group.reload.heading
  end

  test "DELETE #destroy does not delete a group for a published collection" do
    collection = create(:published_document_collection, :with_groups)

    assert_no_difference "collection.groups.count" do
      delete :destroy, params: { document_collection_id: collection, id: collection.groups.first }
    end
    assert_redirected_to admin_document_collection_path(collection)
  end

  test "PUT #order does not reorder groups for a published collection" do
    collection = create(:published_document_collection, :with_groups)
    group1, group2 = collection.groups

    assert_no_changes -> { collection.groups.reload.pluck(:id, :ordering) } do
      put :order, params: { document_collection_id: collection, document_collection_groups: { ordering: { group1.id => "20", group2.id => "10" } } }
    end
    assert_redirected_to admin_document_collection_path(collection)
  end

  test "GET #index is forbidden for an access-limited collection the user cannot see" do
    collection = create(:document_collection, :with_group, :access_limited_by_organisations)

    get :index, params: { document_collection_id: collection }

    assert_response :forbidden
  end

  test "PUT #update is forbidden for an access-limited collection the user cannot see" do
    collection = create(:document_collection, :with_group, :access_limited_by_organisations)
    group = collection.groups.first

    put :update, params: { document_collection_id: collection, id: group, document_collection_group: { heading: "New heading" } }

    assert_response :forbidden
    assert_not_equal "New heading", group.reload.heading
  end

  test "PUT #update is allowed for an access-limited collection the user can see" do
    collection = create(:document_collection, :with_group, :access_limited_by_organisations)
    login_as create(:writer, organisation: collection.access_limiting_organisations.first)

    put :update, params: { document_collection_id: collection, id: collection.groups.first, document_collection_group: { heading: "New heading" } }

    assert_redirected_to admin_document_collection_groups_path(collection)
  end
end
