require 'test_helper'

class Admin::EditionActionsHelperTest < ActionView::TestCase
  test "should generate publish form for edition" do
    edition = create(:submitted_edition, title: "edition-title")
    html = publish_edition_form(edition)
    fragment = Nokogiri::HTML.fragment(html)
    assert_equal publish_admin_document_path(edition, lock_version: edition.lock_version), (fragment/"form").first["action"]
    assert_equal "Publish", (fragment/"input[type=submit]").first["value"]
    assert_equal "Publish edition-title", (fragment/"input[type=submit]").first["title"]
    assert (fragment/"input[type=submit]").first["data-confirm"].blank?
  end

  test "should generate publish form for edition with supporting pages alert" do
    edition = create(:submitted_policy, supporting_pages: [create(:supporting_page)])
    html = publish_edition_form(edition)
    fragment = Nokogiri::HTML.fragment(html)
    assert_equal "Have you checked the 1 supporting pages?", (fragment/"input[type=submit]").first["data-confirm"]
  end

  test "should generate publish form for edition with change note field if required" do
    published_edition = create(:published_edition)
    edition = create(:submitted_edition, doc_identity: published_edition.doc_identity)
    html = publish_edition_form(edition)
    fragment = Nokogiri::HTML.fragment(html)
    refute_nil (fragment/"textarea[name='edition[change_note]']").first
  end

  test "should generate publish form for edition without change note field if not required" do
    edition = create(:submitted_edition)
    html = publish_edition_form(edition)
    fragment = Nokogiri::HTML.fragment(html)
    assert_nil (fragment/"textarea[name='edition[change_note]']").first
  end

  test "should generate force-publish form" do
    edition = create(:submitted_edition, title: "edition-title")
    html = publish_edition_form(edition, force: true)
    fragment = Nokogiri::HTML.fragment(html)
    assert_equal publish_admin_document_path(edition, force: true, lock_version: edition.lock_version), (fragment/"form").first["action"]
    assert_equal "Force Publish", (fragment/"input[type=submit]").first["value"]
    assert_equal "Publish edition-title", (fragment/"input[type=submit]").first["title"]
    assert_equal "Are you sure you want to force publish this document?", (fragment/"input[type=submit]").first["data-confirm"]
  end

  test "should generate force-publish button form with supporting pages alert" do
    edition = create(:submitted_policy, supporting_pages: [create(:supporting_page)])
    html = publish_edition_form(edition, force: true)
    fragment = Nokogiri::HTML.fragment(html)
    assert_equal "Are you sure you want to force publish this document? Have you checked the 1 supporting pages?", (fragment/"input[type=submit]").first["data-confirm"]
  end

  test "should generate force-publish form for edition with change note field if required" do
    published_edition = create(:published_edition)
    edition = create(:submitted_edition, doc_identity: published_edition.doc_identity)
    html = publish_edition_form(edition)
    fragment = Nokogiri::HTML.fragment(html)
    refute_nil (fragment/"textarea[name='edition[change_note]']").first
  end

  test "should generate force-publish form for edition without change note field if not required" do
    edition = create(:submitted_edition)
    html = publish_edition_form(edition)
    fragment = Nokogiri::HTML.fragment(html)
    assert_nil (fragment/"textarea[name='edition[change_note]']").first
  end
end
