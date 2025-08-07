require "test_helper"

class Admin::EditionsSidebarNoticesTest < ActionController::TestCase
  include Admin::EditionRoutesHelper

  setup do
    login_as :writer
    @controller = Admin::NewsArticlesController.new
    @bad_contact_id = "9999999999999"
  end

  view_test "sidebar notices handles editions with no validation errors" do
    edition = create(:draft_news_article, title: "Valid title", body: "Valid body content")
    stub_publishing_api_expanded_links_with_taxons(edition.content_id, [])

    get :show, params: { id: edition }

    assert_response :success
    assert_select ".app-view-summary__sidebar .app-c-inset-prompt--error", count: 0
  end

  view_test "sidebar notices shows specific contact errors and filters out generic messages" do
    edition = create(:draft_news_article, body: "[Contact:#{@bad_contact_id}]")
    edition.save!(validate: false)
    stub_publishing_api_expanded_links_with_taxons(edition.content_id, [])

    get :show, params: { id: edition }

    assert_select ".app-view-summary__sidebar .app-c-inset-prompt--error" do |elements|
      error_text = elements.text
      assert_includes error_text, "Contact ID #{@bad_contact_id} doesn't exist"
      assert_not_includes error_text, "Body is invalid"
      assert_not_includes error_text, "Attachments is invalid"
    end
  end
end
