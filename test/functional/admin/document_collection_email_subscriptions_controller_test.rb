require "test_helper"

class Admin::DocumentCollectionEmailSubscriptionsControllerTest < ActionController::TestCase
  setup do
    @collection = create(:document_collection, :with_group)
    @user_with_permission = create(:writer, permissions: [User::Permissions::EMAIL_OVERRIDE_EDITOR])
    @user_without_permission = create(:writer)
    login_as @user_without_permission
  end

  should_be_an_admin_controller
  should_render_bootstrap_implementation_with_preview_next_release

  view_test "GET #edit renders successfully when the user has the relevant permission" do
    login_as @user_with_permission
    get :edit, params: { document_collection_id: @collection.id }
    assert_response :ok
    assert_select "div", /Choose the type of email updates users will get if they sign up for notifications./
  end

  test "GET #edit redirects to the edit page when the user does not have permission" do
    login_as @user_without_permission
    get :edit, params: { document_collection_id: @collection.id }
    assert_redirected_to admin_document_collection_path(@collection)
  end
end
