require "test_helper"
require "gds_api/test_helpers/link_checker_api"

class LinkCheckerApiReportTest < ActiveSupport::TestCase
  include GdsApi::TestHelpers::LinkCheckerApi

  test "replaces a batch report if it already exists" do
    link = "http://www.example.com"
    publication = create(:publication, body: "[link](#{link})")

    batch_id = 5

    report_payload = link_checker_api_batch_report_hash(
      id: batch_id,
      links: [{ uri: link }],
      status: "completed",
    ).with_indifferent_access

    LinkCheckerApiReport.create!(
      batch_id: batch_id,
      link_reportable: publication,
      status: "in_progress",
    )

    LinkCheckerApiReport.create_from_batch_report(report_payload, publication)

    report = LinkCheckerApiReport.find_by(batch_id: batch_id)
    assert_equal "completed", report.status
  end

  test "creates a noop one for when there are no links" do
    publication = create(:publication, body: "no links")

    LinkCheckerApiReport.create_noop_report(publication)

    assert publication.link_check_reports.last.completed?
  end
end
