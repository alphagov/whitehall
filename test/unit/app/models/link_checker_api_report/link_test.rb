require "test_helper"

class LinkTest < ActiveSupport::TestCase
  test "sets attributes from payload" do
    timestamp = Time.zone.now
    link = LinkCheckerApiReport::Link.new(
      uri: "http://example.com",
      status: "broken",
      checked: timestamp,
      check_dangers: [],
      check_errors: ["Some error"],
      check_warnings: [],
      problem_summary: "Problem",
      suggested_fix: "Fix the left felange",
    )

    assert_equal "http://example.com", link.uri
    assert_equal "broken", link.status
    assert_equal timestamp, link.checked
    assert_equal [], link.check_dangers
    assert_equal ["Some error"], link.check_errors
    assert_equal [], link.check_warnings
    assert_equal "Problem", link.problem_summary
    assert_equal "Fix the left felange", link.suggested_fix
  end

  test "has a `check_details` method that concatenates array, and is agnostic about whether link state is danger/error/warning" do
    link = LinkCheckerApiReport::Link.new(
      check_errors: ["Some error", "Some other error"],
    )
    assert_equal "Some error and Some other error", link.check_details

    link = LinkCheckerApiReport::Link.new(
      check_dangers: ["Some danger", "Danger"],
    )
    assert_equal "Some danger and Danger", link.check_details

    link = LinkCheckerApiReport::Link.new(
      check_warnings: ["Some warning"],
    )
    assert_equal "Some warning", link.check_details
  end
end
