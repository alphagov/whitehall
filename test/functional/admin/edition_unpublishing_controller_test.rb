require 'test_helper'

class Admin::EditionUnpublishingControllerTest < ActionController::TestCase
  include Admin::EditionRoutesHelper
  should_be_an_admin_controller

  def setup
    login_as(create(:managing_editor))
    @edition = create(:withdrawn_edition)
  end

  test "#edit loads the unpublishing and renders the unpublish edit template" do
    unpublishing = create(:unpublishing, edition: @edition)

    get :edit, edition_id: @edition.id

    assert_response :success
    assert_template :edit
    assert_equal unpublishing, assigns(:unpublishing)
  end

  test "#update updates the unpublishing and redirects to admin policy page" do
    unpublishing = create(:unpublishing, edition: @edition, explanation: "Content is mislidding")

    put :update, edition_id: @edition.id, unpublishing: { explanation: "Content is misleading" }

    assert_redirected_to admin_edition_path(@edition)
    assert_equal "The public explanation was updated", flash[:notice]
    assert_equal "Content is misleading", unpublishing.reload.explanation
  end

  test "#update shows form with error if the update was not possible" do
    unpublishing = create(:unpublishing, edition: @edition, explanation: "Content is mislidding",
      unpublishing_reason_id: UnpublishingReason::Withdrawn.id)

    put :update, edition_id: @edition, unpublishing: { explanation: nil }

    assert_template :edit
    assert_equal "The public explanation could not be updated", flash[:alert]
    assert_equal "Content is mislidding", unpublishing.reload.explanation
  end

end
