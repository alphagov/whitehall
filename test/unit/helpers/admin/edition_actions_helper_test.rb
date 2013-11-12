require 'test_helper'

class Admin::EditionActionsHelperTest < ActionView::TestCase
  test "should generate publish form for edition" do
    edition = create(:submitted_edition, title: "edition-title")
    html = publish_edition_form(edition)
    fragment = Nokogiri::HTML.fragment(html)
    assert_equal publish_admin_edition_path(edition, lock_version: edition.lock_version), (fragment/"form").first["action"]
    assert_equal "Publish", (fragment/"input[type=submit]").first["value"]
    assert_equal "Publish edition-title", (fragment/"input[type=submit]").first["title"]
    assert (fragment/"input[type=submit]").first["data-confirm"].blank?
  end

  test "should generate force-publish modal button" do
    edition = create(:submitted_edition, title: "edition-title")
    html = publish_edition_form(edition, force: true)
    fragment = Nokogiri::HTML.fragment(html)
    assert_equal "Force publish", (fragment/"a").first.text
    assert_equal "modal", (fragment/"a").first["data-toggle"]
    assert_equal "#forcePublishModal", (fragment/"a").first["data-target"]
  end
end
