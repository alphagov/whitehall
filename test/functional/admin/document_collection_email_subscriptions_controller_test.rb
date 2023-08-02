require "test_helper"

class Admin::DocumentCollectionEmailSubscriptionsControllerTest < ActionController::TestCase
  setup do
    @collection = create(:document_collection, :with_group)
    @user_with_permission = create(:writer, permissions: [User::Permissions::EMAIL_OVERRIDE_EDITOR])
    @user_without_permission = create(:writer)
    @selected_taxon_content_id = "9b889c60-2191-11ee-be56-0242ac120002"
    @put_params = {
      document_collection_id: @collection.id,
      override_email_subscriptions: "true",
      selected_taxon_content_id: @selected_taxon_content_id,
      email_override_confirmation: "true",
    }
    login_as @user_without_permission
  end

  should_be_an_admin_controller

  view_test "GET #edit renders successfully when the user has the relevant permission" do
    login_as @user_with_permission
    get :edit, params: { document_collection_id: @collection.id }
    assert_response :ok
    assert_select "div", /Choose the type of email updates users will get if they sign up for notifications./
  end

  test "GET #edit redirects to the edit page when the user does not have permission" do
    login_as @user_without_permission
    get :edit, params: { document_collection_id: @collection.id }
    assert_redirected_to edit_admin_document_collection_path(@collection)
  end

  test "PUT #edit successfully updates a document collection when the user has permission" do
    login_as @user_with_permission
    put :update, params: @put_params
    @collection.reload

    assert_equal @collection.taxonomy_topic_email_override, @selected_taxon_content_id
    assert_redirected_to edit_admin_document_collection_path(@collection)
  end

  test "PUT #edit does not update a document collection when the user does not have permission" do
    login_as @user_without_permission
    put :update, params: @put_params
    @collection.reload

    assert_nil @collection.taxonomy_topic_email_override
    assert_redirected_to edit_admin_document_collection_path(@collection)
  end

  test "PUT #edit does not update a document collection when the confirmation field is not present" do
    login_as @user_with_permission
    put :update, params: @put_params.reject { |k| k == :email_override_confirmation }
    @collection.reload

    assert_nil @collection.taxonomy_topic_email_override
    assert_redirected_to admin_document_collection_edit_email_subscription_path(@collection)
  end

  test "PUT #edit does not update a document collection when the selected_taxon_content_id field is not present" do
    login_as @user_with_permission
    put :update, params: @put_params.reject { |k| k == :selected_taxon_content_id }
    @collection.reload

    assert_nil @collection.taxonomy_topic_email_override
    assert_redirected_to admin_document_collection_edit_email_subscription_path(@collection)
  end

  test "PUT #edit successfully updates taxonomy topic override of a draft document collection" do
    login_as @user_with_permission
    collection = create(:draft_document_collection, taxonomy_topic_email_override: @selected_taxon_content_id)

    params = {
      document_collection_id: collection.id,
      override_email_subscriptions: "false",
    }

    put(:update, params:)
    collection.reload

    assert_nil collection.taxonomy_topic_email_override
    assert_redirected_to edit_admin_document_collection_path(collection)
  end
end
