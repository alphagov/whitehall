require "test_helper"

class Admin::DraftEditionChangeNotesControllerTest < ActionController::TestCase
  include Admin::EditionRoutesHelper

  setup do
    login_as :gds_admin
    @edition = create(:edition, change_note: "Change note", minor_change: false)
  end

  should_be_an_admin_controller

  test "GET :edit assigns the correct " do
    get :edit, params: { edition_id: @edition.id }

    assert_response :success
    assert_equal @edition, assigns(:edition)
    assert_equal "Change note", assigns(:change_note_form).change_note
    assert_equal false, assigns(:change_note_form).minor_change
  end

  test "PATCH :update updates an editions change note and version" do
    patch :update,
          params: {
            edition_id: @edition.id,
            change_note_form: {
              change_note: "New change note!",
              minor_change: "false",
            },
          }

    assert_equal "New change note!", @edition.reload.change_note
  end

  test "PATCH :update re-renders the :edit template when invalid data is passed" do
    patch :update,
          params: {
            edition_id: @edition.id,
            change_note_form: {
              change_note: nil,
              minor_change: "false",
            },
          }

    assert_template :edit
  end

  %i[edit update].each do |action_method|
    test "#{action_method} redirects back to the document summary page if edition is not editable" do
      edition = create(:published_edition)

      get action_method, params: { edition_id: edition.id }
      assert_redirected_to @controller.admin_edition_path(edition)
    end
  end
end
