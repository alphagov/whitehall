require 'test_helper'

class CreateEditionLinkMonitorTest < ActiveSupport::TestCase
  setup do
    Whitehall.link_checker_api_client.stubs(:upsert_resource_monitor).returns {}
  end

  def expect_link_checker_api_call
    Whitehall.link_checker_api_client.expects(:upsert_resource_monitor)
      .with(any_parameters)
  end

  test '#perform! with a valid edition that has links calls the LinkCheckerApi' do
    edition = create(:submitted_edition, body: "[Example](https://www.gov.uk/)")

    expect_link_checker_api_call
    assert CreateEditionLinkMonitor.new(edition).perform!
  end

  test 'an edition without links should not be monitored' do
    edition = create(:submitted_edition, body: "no links")
    link_monitor = CreateEditionLinkMonitor.new(edition)

    refute link_monitor.can_perform?
    assert_equal "This edition has no links", link_monitor.failure_reason
  end
end
