require 'test_helper'

class Admin::DocumentActionsHelperTest < ActionView::TestCase
  test "should generate publish button form for document" do
    document = create(:submitted_document, title: "document-title")
    html = publish_document_button(document)
    fragment = Nokogiri::HTML.fragment(html)
    assert_equal admin_document_publishing_path(document), (fragment/"form").first["action"]
    refute_nil (fragment/"input[name='document[lock_version]'][type=hidden]").first
    assert_equal "Publish", (fragment/"input[type=submit]").first["value"]
    assert_equal "Publish document-title", (fragment/"input[type=submit]").first["title"]
    assert_nil (fragment/"input[type=submit]").first["data-confirm"]
  end

  test "should generate publish button form for document with supporting pages alert" do
    document = create(:submitted_policy, supporting_pages: [create(:supporting_page)])
    publishing_path = admin_document_publishing_path(document)
    html = publish_document_button(document)
    fragment = Nokogiri::HTML.fragment(html)
    assert_equal "Have you checked the 1 supporting pages?", (fragment/"input[type=submit]").first["data-confirm"]
  end

  test "should generate force-publish button form" do
    document = create(:submitted_document, title: "document-title")
    html = force_publish_document_button(document)
    fragment = Nokogiri::HTML.fragment(html)
    assert_equal admin_document_publishing_path(document, force: true), (fragment/"form").first["action"]
    refute_nil (fragment/"input[name='document[lock_version]'][type=hidden]").first
    assert_equal "Force Publish", (fragment/"input[type=submit]").first["value"]
    assert_equal "Publish document-title", (fragment/"input[type=submit]").first["title"]
    assert_equal "Are you sure you want to force publish this document?", (fragment/"input[type=submit]").first["data-confirm"]
  end

  test "should generate force-publish button form with supporting pages alert" do
    document = create(:submitted_policy, supporting_pages: [create(:supporting_page)])
    html = force_publish_document_button(document)
    fragment = Nokogiri::HTML.fragment(html)
    assert_equal "Are you sure you want to force publish this document? Have you checked the 1 supporting pages?", (fragment/"input[type=submit]").first["data-confirm"]
  end
end
