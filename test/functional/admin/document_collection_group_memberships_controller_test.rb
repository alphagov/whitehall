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
    get :index, params: { document_collection_id: @collection, group_id: @group }

    assert_select ".govuk-link[href='#']", text: "Add document"
    assert_select ".govuk-warning-text__text", text: /There are no documents inside this group/
  end

  view_test "GET #index renders a link to add a document and a table of memberships with view and delete links" do
    document = create(:document)
    edition = create(:edition, document:)
    membership = create(:document_collection_group_membership, document:)
    confirm_destroy_path = confirm_destroy_admin_document_collection_group_document_collection_group_membership_path(@collection, @group, membership)

    @group.memberships << membership

    get :index, params: { document_collection_id: @collection, group_id: @group }

    assert_select ".govuk-link[href='#']", text: "Add document"
    assert_select ".govuk-table__row:nth-child(1) .govuk-table__cell:nth-child(2) a[href='#{edition.public_url}']", text: "View #{edition.title}"
    assert_select ".govuk-table__row:nth-child(1) .govuk-table__cell:nth-child(2) a[href='#{confirm_destroy_path}']", text: "Delete #{edition.title}"
  end
end
