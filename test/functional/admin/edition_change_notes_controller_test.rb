require "test_helper"

class Admin::EditionChangeNotesControllerTest < ActionController::TestCase
  setup do
    login_as :gds_admin

    @document = create(:document)
    create(:edition, :superseded, change_note: "First change note", major_change_published_at: "2022-12-01 10:00:05", document: @document)
    @second_edition = create(:edition, :superseded, change_note: "Second change note", major_change_published_at: "2022-12-02 15:00:05", document: @document)
    @current_edition = create(:edition, :published, change_note: "Third change note", major_change_published_at: "2022-12-03 12:02:05", document: @document)
  end

  should_be_an_admin_controller

  test "GDS admin permission required to access index" do
    login_as :gds_editor

    get :index, params: { edition_id: @current_edition.id }

    assert_response 403
  end

  view_test "index lists all the published major changes" do
    login_as :gds_admin

    get :index, params: { edition_id: @current_edition.id }

    assert_select "td", text: "1 December 2022 10:00am"
    assert_select "td", text: "First change note"

    assert_select "td", text: "2 December 2022  3:00pm"
    assert_select "td", text: "Second change note"

    assert_select "td", text: "3 December 2022 12:02pm"
    assert_select "td", text: "Third change note"
  end

  view_test "index does not list the minor changes" do
    login_as :gds_admin

    @current_edition.update!(state: "superseded")
    create(:edition, :draft, change_note: "Draft edition change note", major_change_published_at: "2022-12-04 12:02:05", document: @document)

    get :index, params: { edition_id: @current_edition.id }

    refute_select "td", text: "2 December 2022  4:00pm"
  end

  view_test "index does not list the unpublished changes" do
    login_as :gds_admin

    get :index, params: { edition_id: @current_edition.id }

    refute_select "td", text: "4 December 2022 12:00am"
    refute_select "td", text: "Draft edition change note"
  end
end
