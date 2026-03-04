require "test_helper"
require "gds_api/test_helpers/link_checker_api"

class LinkCheckerApiReportTest < ActiveSupport::TestCase
  include GdsApi::TestHelpers::LinkCheckerApi

  test "creates a noop one for when there are no links" do
    publication = create(:publication, body: "no links")

    LinkCheckerApiReport.create_noop_report(publication)

    assert publication.reload.link_check_report.completed?
  end

  test "deletes any previous ones" do
    edition = create(:publication, body: "no links")
    LinkCheckerApiReport.create!(
      batch_id: 123,
      edition:,
      status: "completed",
    )

    LinkCheckerApiReport.create_noop_report(edition)

    assert LinkCheckerApiReport.where(edition:).count == 1
  end

  test "creates a RemoveDangerousLinksJob if dangerous links detected" do
    edition = create(:publication, body: "[dangerous link](http://www.example.com)")
    report = LinkCheckerApiReport.create!(
      batch_id: 300,
      edition: edition,
      status: "in_progress",
    )
    batch_report = link_checker_api_batch_report_hash(
      id: 300,
      status: "completed",
      links: [
        {
          uri: "http://www.example.com",
          status: "danger",
          danger: ["This link is hosted on a domain which is on our list of suspicious domains"],
        },
      ],
    ).with_indifferent_access

    RemoveDangerousLinksJob.expects(:perform_async).once

    report.mark_report_as_completed(batch_report)
  end

  test "doesn't create RemoveDangerousLinksJob if no dangerous links are detected" do
    edition = create(:publication, body: "[broken link](http://www.example.com/broken) [warning link](http://www.example.com/warning)")
    report = LinkCheckerApiReport.create!(
      batch_id: 123,
      edition: edition,
      status: "in_progress",
    )
    batch_report = link_checker_api_batch_report_hash(
      id: 123,
      status: "completed",
      links: [
        {
          uri: "http://www.example.com/broken",
          status: "broken",
          errors: ["broken link"],
        },
        {
          uri: "http://www.example.com/warning",
          status: "caution",
          warnings: ["This link is hosted on a domain which is on our list of suspicious domains"],
        },
      ],
    ).with_indifferent_access

    RemoveDangerousLinksJob.expects(:perform_async).never

    report.mark_report_as_completed(batch_report)
  end
end
