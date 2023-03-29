# frozen_string_literal: true

require "test_helper"

class Admin::Editions::TagsComponentTest < ViewComponent::TestCase
  [
    {
      state: :force_published,
      expected_tag_classes: "govuk-tag govuk-tag--s govuk-tag--yellow",
      label_text: "Force published",
    },
    {
      state: :draft,
      expected_tag_classes: "govuk-tag govuk-tag--s govuk-tag--blue",
      label_text: "Draft",
    },
    {
      state: :submitted,
      expected_tag_classes: "govuk-tag govuk-tag--s",
      label_text: "Submitted",
    },
    {
      state: :published,
      expected_tag_classes: "govuk-tag govuk-tag--s govuk-tag--green",
      label_text: "Published",
    },
    {
      state: :scheduled,
      expected_tag_classes: "govuk-tag govuk-tag--s govuk-tag--turquoise",
      label_text: "Scheduled",
    },
    {
      state: :rejected,
      expected_tag_classes: "govuk-tag govuk-tag--s govuk-tag--red",
      label_text: "Rejected",
    },
    {
      state: :withdrawn,
      expected_tag_classes: "govuk-tag govuk-tag--s govuk-tag--grey",
      label_text: "Withdrawn",
    },
    {
      state: :unpublished,
      expected_tag_classes: "govuk-tag govuk-tag--s govuk-tag--grey",
      label_text: "Unpublished",
    },
  ].each do |hash|
    test "returns the correct tag for the #{hash[:state]} state" do
      edition = create(:edition, hash[:state])

      expected_output = "<span class=\"#{hash[:expected_tag_classes]}\">#{hash[:label_text]}</span>"
      output = render_inline(Admin::Editions::TagsComponent.new(edition)).to_html.strip

      assert_equal expected_output, output
    end
  end

  test "adds an access limited tag if edition has limited access" do
    edition = build(:edition, access_limited: true)

    expected_output = "<span class=\"govuk-tag govuk-tag--s govuk-tag--blue\">Draft</span> " \
      "<span class=\"govuk-tag govuk-tag--s govuk-tag--red\">Limited access</span>"
    output = render_inline(Admin::Editions::TagsComponent.new(edition)).to_html.strip

    assert_equal expected_output, output
  end

  test "adds a broken links tag if the last report has broken links" do
    edition = build(:edition)
    links_report = build(:link_checker_api_report_completed, link_reportable: edition)
    broken_link = build(:link_checker_api_report_link, :broken, link_checker_api_report_id: links_report.id)

    edition.stubs(:link_check_reports).returns([links_report])
    links_report.stubs(:broken_links).returns([broken_link])

    expected_output = "<span class=\"govuk-tag govuk-tag--s govuk-tag--blue\">Draft</span> " \
      "<span class=\"govuk-tag govuk-tag--s govuk-tag--red\">Broken links</span>"
    output = render_inline(Admin::Editions::TagsComponent.new(edition)).to_html.strip

    assert_equal expected_output, output
  end

  test "adds a links warning tag if the last report has caution links" do
    edition = build(:edition)
    links_report = build(:link_checker_api_report_completed, link_reportable: edition)
    caution_link = build(:link_checker_api_report_link, status: "caution")

    edition.stubs(:link_check_reports).returns([links_report])
    links_report.stubs(:caution_links).returns([caution_link])

    expected_output = "<span class=\"govuk-tag govuk-tag--s govuk-tag--blue\">Draft</span> " \
      "<span class=\"govuk-tag govuk-tag--s govuk-tag--yellow\">Link warnings</span>"
    output = render_inline(Admin::Editions::TagsComponent.new(edition)).to_html.strip

    assert_equal expected_output, output
  end
end
