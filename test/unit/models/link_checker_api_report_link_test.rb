require "test_helper"

class LinkCheckerApiReportLinkTest < ActiveSupport::TestCase
  test "with a broken link, don't mark as deletable" do
    create(:link_checker_api_report_link, :broken)
    assert_equal LinkCheckerApiReport::Link.deletable.to_a, []
  end

  test "with an ok link, don't mark as deletable" do
    create(:link_checker_api_report_link)
    assert_equal LinkCheckerApiReport::Link.deletable.to_a, []
  end

  test "with an ok link created over 3 months ago, mark as deletable" do
    link = create(:link_checker_api_report_link, created_at: (3.months + 1.day).ago)
    assert_equal LinkCheckerApiReport::Link.deletable.to_a, [link]
  end
end
