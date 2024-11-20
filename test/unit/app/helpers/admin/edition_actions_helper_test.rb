require "test_helper"

class Admin::EditionActionsHelperTest < ActionView::TestCase
  setup do
    @editions = ["Case studies",
                 "Calls for evidence",
                 "Consultations",
                 "Corporate information pages",
                 "Detailed guidances",
                 "Document collections",
                 "News articles",
                 "Publications",
                 "Speeches",
                 "Statistical data sets",
                 "Worldwide organisations"]
  end

  test "should generate publish form for edition" do
    edition = create(:submitted_edition, title: "edition-title")
    html = publish_edition_form(edition)
    fragment = Nokogiri::HTML.fragment(html)
    assert_equal confirm_publish_admin_edition_path(edition, lock_version: edition.lock_version), (fragment / "form").first["action"]
    assert_equal "Publish", (fragment / "input[type=submit]").first["value"]
    assert_equal "Publish edition-title", (fragment / "input[type=submit]").first["title"]
    assert((fragment / "input[type=submit]").first["data-confirm"].blank?)
  end

  test "should generate force-publish link button" do
    edition = create(:submitted_edition, title: "edition-title")
    html = publish_edition_form(edition, force: true)
    fragment = Nokogiri::HTML.fragment(html)
    assert_equal confirm_force_publish_admin_edition_path(edition, lock_version: edition.lock_version), (fragment / "a").first["href"]
  end

  test "#filter_edition_type_opt_groups should contain a formatted list of the editions" do
    filter_options = filter_edition_type_opt_groups(create(:user), nil)
    types = filter_options[1].last.map { |type| type[:text] }

    assert_same_elements @editions, types
  end

  test "#filter_edition_type_opt_groups should include fatality notices when the user can handle fatalities" do
    filter_options = filter_edition_type_opt_groups(create(:gds_editor), nil)
    types = filter_options[1].last.map { |type| type[:text] }

    assert_same_elements @editions + ["Fatality notices"], types
  end

  test "#filter_edition_type_opt_groups should include landing pages when the user is an admin" do
    filter_options = filter_edition_type_opt_groups(create(:gds_admin), nil)
    types = filter_options[1].last.map { |type| type[:text] }

    assert_same_elements @editions + ["Fatality notices", "Landing pages"], types
  end
end
