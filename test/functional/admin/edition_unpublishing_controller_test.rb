require 'test_helper'

class Admin::EditionUnpublishingControllerTest < ActionController::TestCase
  include Admin::EditionRoutesHelper
  should_be_an_admin_controller

  def setup
    @user = create(:managing_editor)
    login_as(@user)
    @edition = create(:withdrawn_edition)
  end

  test "#edit loads the unpublishing and renders the unpublish edit template" do
    unpublishing = @edition.unpublishing
    get :edit, params: { edition_id: @edition.id }

    assert_response :success
    assert_template :edit
    assert_equal unpublishing, assigns(:unpublishing)
  end

  test "#update updates the withdrawal and redirects to admin policy page" do
    Whitehall.edition_services
      .expects(:withdrawer)
      .with(@edition, user: @user)
      .returns(withdrawer = stub)

    withdrawer.expects(:perform!)


    put :update, params: { edition_id: @edition.id, unpublishing: { explanation: "this used to say withdrawn" } }

    assert_redirected_to admin_edition_path(@edition)
    assert_equal "The public explanation was updated", flash[:notice]
    assert_equal "this used to say withdrawn", @edition.unpublishing.reload.explanation
  end

  test "#update updates the unpublishing and redirects to admin policy page" do
    @unpublished_edition = create(:unpublished_edition)

    Whitehall.edition_services
      .expects(:unpublisher)
      .with(@unpublished_edition)
      .returns(unpublisher = stub)

    unpublisher.expects(:perform!)

    put :update, params: { edition_id: @unpublished_edition.id, unpublishing: { explanation: "this used to say unpublished" } }

    assert_redirected_to admin_edition_path(@unpublished_edition)
    assert_equal "The public explanation was updated", flash[:notice]
    assert_equal "this used to say unpublished", @unpublished_edition.unpublishing.reload.explanation
  end

  test "#update shows form with error if the update was not possible" do
    unpublishing = @edition.unpublishing
    original_explanation = unpublishing.explanation
    put :update, params: { edition_id: @edition, unpublishing: { explanation: nil } }

    assert_template :edit
    assert_equal "The public explanation could not be updated", flash[:alert]
    assert_equal original_explanation, unpublishing.reload.explanation
  end
end
