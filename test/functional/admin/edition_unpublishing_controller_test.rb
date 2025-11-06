require "test_helper"

class Admin::EditionUnpublishingControllerTest < ActionController::TestCase
  include Admin::EditionRoutesHelper
  should_be_an_admin_controller

  def setup
    @user = create(:managing_editor)
    login_as(@user)
  end

  view_test "#edit loads the unpublishing and renders the edit form" do
    edition = create(:edition, :published_in_error_redirect)
    get :edit, params: { edition_id: edition.id }

    assert_response :success
    assert_template :edit
    assert_equal edition.unpublishing, assigns(:unpublishing)
    assert_dom "textarea[name=\"unpublishing[explanation]\"]"
    assert_dom "input[name=\"unpublishing[alternative_url]\"]"
  end

  view_test "#edit loads the consolidated unpublishing and renders the edit form" do
    edition = create(:edition, :consolidated_redirect)
    get :edit, params: { edition_id: edition.id }

    assert_response :success
    assert_template :edit
    assert_equal edition.unpublishing, assigns(:unpublishing)
    refute_dom "textarea[name=\"unpublishing[explanation]\"]"
    assert_dom "input[name=\"unpublishing[alternative_url]\"]"
  end

  view_test "#edit loads the withdrawal and renders the edit form" do
    edition = create(:edition, :withdrawn)
    get :edit, params: { edition_id: edition.id }

    assert_response :success
    assert_template :edit
    assert_equal edition.unpublishing, assigns(:unpublishing)
    assert_dom "textarea[name=\"unpublishing[explanation]\"]"
    refute_dom "input[name=\"unpublishing[alternative_url]\"]"
  end

  test "#update updates the withdrawal and redirects to admin policy page" do
    edition = create(:edition, :withdrawn)
    Whitehall.edition_services
      .expects(:withdrawer)
      .with(edition, user: @user)
      .returns(withdrawer = stub)

    withdrawer.expects(:perform!)

    put :update, params: { edition_id: edition.id, unpublishing: { explanation: "this used to say withdrawn" } }

    assert_redirected_to @controller.admin_edition_path(edition)
    assert_equal "The withdrawal was updated", flash[:notice]
    assert_equal "this used to say withdrawn", edition.unpublishing.reload.explanation
  end

  test "#update updates the unpublishing and redirects to admin policy page" do
    edition = create(:edition, :published_in_error_redirect)

    Whitehall.edition_services
      .expects(:unpublisher)
      .with(edition)
      .returns(unpublisher = stub)

    unpublisher.expects(:perform!)

    put :update, params: { edition_id: edition.id,
                           unpublishing: {
                             explanation: "this used to say unpublished",
                             alternative_url: "https://gov.uk/some-page",
                           } }

    assert_redirected_to @controller.admin_edition_path(edition)
    assert_equal "The unpublishing was updated", flash[:notice]
    assert_equal "this used to say unpublished", edition.unpublishing.reload.explanation
    assert_equal "https://gov.uk/some-page", edition.unpublishing.reload.alternative_url
  end

  view_test "#updating the withdrawal shows the error message if the update was not possible" do
    edition = create(:edition, :withdrawn)
    original_explanation = edition.unpublishing.explanation
    put :update, params: { edition_id: edition, unpublishing: { explanation: "" } }

    assert_template :edit
    assert_equal original_explanation, edition.unpublishing.reload.explanation

    error = assigns(:unpublishing).errors.where("explanation").first
    assert_dom ".govuk-error-message", text: "Error: #{error.full_message}"
  end

  view_test "#updating the unpublishing shows the error message if the update was not possible" do
    edition = create(:edition, :published_in_error_redirect)
    put :update, params: { edition_id: edition.id, unpublishing: { explanation: "", alternative_url: "not a URL" } }

    errors = assigns(:unpublishing).errors.where(:alternative_url)
    assert_dom ".govuk-error-message", text: "Error: #{errors.map(&:full_message).join}"
  end
end
