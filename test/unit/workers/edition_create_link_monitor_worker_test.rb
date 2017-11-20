require 'test_helper'

class EditionCreateLinkMonitorWorkerTest < ActiveSupport::TestCase
  setup do
    @edition = create(:submitted_edition)
    @link_monitor = CreateEditionLinkMonitor.new(@edition)
    CreateEditionLinkMonitor.any_instance.stubs(:perform!).returns true
  end

  test "#perform calls CreateEditionLinkMonitor when valid" do
    CreateEditionLinkMonitor.expects(:new).with(@edition).returns(@link_monitor)

    worker_invocation = EditionCreateLinkMonitorWorker.new.perform(@edition.id)

    assert worker_invocation
    assert_equal true, worker_invocation
  end

  test "#perform doesn't call CreateEditionLinkMonitor edition not found" do
    refute_equal EditionCreateLinkMonitorWorker.new.perform(1221), true
  end
end
