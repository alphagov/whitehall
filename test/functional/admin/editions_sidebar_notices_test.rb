require "test_helper"

class Admin::EditionsSidebarNoticesTest < ActionController::TestCase
  include Admin::EditionRoutesHelper

  setup do
    login_as :writer
    @controller = Admin::NewsArticlesController.new
    @bad_contact_id = "99999"
  end

  view_test "sidebar notices handles editions with no validation errors" do
    edition = create(:draft_news_article, title: "Valid title", body: "Valid body content")
    stub_publishing_api_expanded_links_with_taxons(edition.content_id, [])

    get :show, params: { id: edition }

    assert_response :success
    assert_select ".app-view-summary__sidebar .app-c-inset-prompt--error", count: 0
  end

  view_test "sidebar notices shows validation errors from edition" do
    edition = create(:draft_news_article, body: "[Contact:#{@bad_contact_id}]")
    edition.save!(validate: false)
    stub_publishing_api_expanded_links_with_taxons(edition.content_id, [])

    get :show, params: { id: edition }

    assert_select ".app-view-summary__sidebar .app-c-inset-prompt--error" do |elements|
      error_text = elements.text
      assert_includes error_text, "This edition is invalid"
    end
  end

  view_test "sidebar notices shows specific validation errors without generic association messages" do
    edition = create(:draft_news_article, body: "[Contact:#{@bad_contact_id}]")
    stub_publishing_api_expanded_links_with_taxons(edition.content_id, [])

    get :show, params: { id: edition }

    assert_select ".app-view-summary__sidebar .app-c-inset-prompt--error" do |elements|
      error_text = elements.text
      assert_includes error_text, "This edition is invalid"
      assert_includes error_text, "Contact ID"
      assert_includes error_text, "doesn't exist"
    end
  end

  view_test "sidebar notices keeps generic association errors when no specific contact errors exist" do
    edition = create(:draft_news_article, title: "Valid title", body: "Valid body")
    stub_publishing_api_expanded_links_with_taxons(edition.content_id, [])

    get :show, params: { id: edition }

    assert_response :success
  end
end
