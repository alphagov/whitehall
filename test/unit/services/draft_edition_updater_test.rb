require 'test_helper'

class DraftEditionUpdaterTest < ActiveSupport::TestCase
  test "#perform! calls notify! without modifying the edition" do
    edition = create(:draft_edition)
    edition.freeze
    updater = DraftEditionUpdater.new(edition)
    updater.expects(:update_publishing_api!).once
    updater.expects(:notify!).once

    updater.perform!
  end

  test "cannot perform if edition is invalid" do
    edition = Edition.new
    updater = DraftEditionUpdater.new(edition)
    updater.expects(:notify!).never
    updater.expects(:update_publishing_api!).never

    updater.perform!
  end

  test "cannot perform if edition is not draft" do
    edition = create(:published_edition)
    updater = DraftEditionUpdater.new(edition)
    updater.expects(:notify!).never
    updater.expects(:update_publishing_api!).never

    updater.perform!
  end
end
