require "test_helper"

class LinkCheckReportValidatorTest < ActiveSupport::TestCase
  setup do
    @validator = LinkCheckReportValidator.new
  end

  test "is invalid when edition contains 'dangerous' links" do
    edition = create(:draft_edition)
    create(
      :link_checker_api_report_completed,
      edition: edition,
      links: [
        create(:link_checker_api_report_link, :danger, uri: "http://www.example.com"),
      ],
    )

    @validator.validate(edition)

    assert_equal 1, edition.errors.count
    assert_equal(
      "This document has not been published. You need to remove dangerous links before publishing.",
      edition.errors[:base].first,
    )
  end

  test "is valid when edition contains 'broken' links" do
    edition = create(:draft_edition)
    create(
      :link_checker_api_report_completed,
      edition: edition,
      links: [
        create(:link_checker_api_report_link, :broken, uri: "http://www.example.com"),
      ],
    )

    @validator.validate(edition)

    assert_equal 0, edition.errors.count
  end

  test "is valid when edition contains no link check report" do
    edition = create(:draft_edition)

    @validator.validate(edition)

    assert_equal 0, edition.errors.count
  end
end
