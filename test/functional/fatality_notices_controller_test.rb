require 'test_helper'

class FatalityNoticesControllerTest < ActionController::TestCase
  should_be_a_public_facing_controller
  should_display_inline_images_for :fatality_notice

  test "shows published fatality notices" do
    fatality_notice = create(:published_fatality_notice)
    get :show, id: fatality_notice.document
    assert_response :success
  end

  view_test "renders the fatality notice summary from plain text" do
    fatality_notice = create(:published_fatality_notice, summary: 'plain text & so on')
    get :show, id: fatality_notice.document

    assert_select ".summary", text: "plain text &amp; so on"
  end

  view_test "renders the fatality notice body using govspeak" do
    fatality_notice = create(:published_fatality_notice, body: "body-in-govspeak")
    govspeak_transformation_fixture "body-in-govspeak" => "body-in-html" do
      get :show, id: fatality_notice.document
    end

    assert_select ".body", text: "body-in-html"
  end

  view_test "shows when updated fatality notice was first published and last updated" do
    fatality_notice = create(:published_fatality_notice, first_published_at: 10.days.ago)

    editor = create(:departmental_editor)
    updated_fatality_notice = fatality_notice.create_draft(editor)
    updated_fatality_notice.change_note = "change-note"
    force_publish(updated_fatality_notice)

    get :show, id: updated_fatality_notice.document

    assert_select ".meta" do
      assert_select ".published-at[title='#{fatality_notice.first_published_at.iso8601}']"
      assert_select ".published-at[title='#{updated_fatality_notice.public_timestamp.iso8601}']"
    end
  end

  test "the format name is being set to news" do
    fatality_notice = create(:published_fatality_notice)

    get :show, id: fatality_notice.document

    assert_equal "news", response.headers["X-Slimmer-Format"]
  end
end
