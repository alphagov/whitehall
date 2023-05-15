require "test_helper"
require "gds_api/test_helpers/publishing_api"

class Admin::DocumentsControllerTest < ActionController::TestCase
  include GdsApi::TestHelpers::PublishingApi

  def setup
    login_as :user
    @document = create(:edition, :with_document).document
  end

  view_test "GET by-content-id redirects to content by content_id" do
    get :by_content_id, params: { content_id: @document.content_id }
    assert_redirected_to @controller.admin_edition_path(@document.latest_edition)
  end

  view_test "GET by-content-id supports HTML Attachments" do
    attachment = create(:html_attachment)
    document = attachment.attachable.document

    get :by_content_id, params: { content_id: attachment.content_id }
    assert_redirected_to @controller.admin_edition_path(document.latest_edition)
  end

  view_test "GET by-content-id redirects to a search if content_id is not found" do
    get :by_content_id, params: { content_id: "#{@document.content_id}wrong-id" }
    assert_redirected_to admin_editions_path
  end
end
