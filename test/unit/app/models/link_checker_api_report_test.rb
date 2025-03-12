require "test_helper"
require "gds_api/test_helpers/link_checker_api"

class LinkCheckerApiReportTest < ActiveSupport::TestCase
  include GdsApi::TestHelpers::LinkCheckerApi

  test "creates a noop one for when there are no links" do
    publication = create(:publication, body: "no links")

    LinkCheckerApiReport.create_noop_report(publication)

    assert publication.link_check_reports.last.completed? # TODO: delete this line
    assert publication.link_check_report.completed?
  end
end
