require "test_helper"

class Admin::DocumentCollectionEmailSubscriptionsControllerTest < ActionController::TestCase
  include TaxonomyHelper
  setup do
    @collection = create(:draft_document_collection, :with_group)
    @user_with_permission = create(:writer, permissions: [User::Permissions::EMAIL_OVERRIDE_EDITOR])
    @user_without_permission = create(:writer)
    @selected_taxon_content_id = root_taxon_content_id
    @put_params = {
      document_collection_id: @collection.id,
      override_email_subscriptions: "true",
      selected_taxon_content_id: @selected_taxon_content_id,
      email_override_confirmation: "true",
    }
    login_as @user_without_permission
    stub_publishing_api_has_item(content_id: root_taxon_content_id, title: root_taxon["title"])
    stub_taxonomy_with_all_taxons
  end

  should_be_an_admin_controller

  view_test "GET #edit renders successfully when the user has the relevant permission" do
    login_as @user_with_permission
    get :edit, params: { document_collection_id: @collection.id }
    assert_response :ok
    assert_select "div", /You cannot change the email notifications for this document collection/
  end

  test "GET #edit redirects to the edit page when the user does not have permission" do
    login_as @user_without_permission
    get :edit, params: { document_collection_id: @collection.id }
    assert_redirected_to edit_admin_document_collection_path(@collection)
  end
end
