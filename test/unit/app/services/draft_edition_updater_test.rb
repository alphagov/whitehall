require "test_helper"

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

  test "cannot perform if user is limiting their own access" do
    edition = create(:draft_news_article, access_limited: true, organisations: [create(:organisation)])
    updater = DraftEditionUpdater.new(edition, { current_user: create(:user, organisation: create(:organisation)) })
    updater.expects(:notify!).never
    updater.expects(:update_publishing_api!).never

    updater.perform!
  end

  test "updates editions that cannot be tagged to organisations" do
    organisation = create(:organisation)
    edition = create(:draft_corporate_information_page, organisation:, access_limited: true)
    updater = DraftEditionUpdater.new(edition, { current_user: create(:user, organisation:) })
    updater.expects(:update_publishing_api!).once
    updater.expects(:notify!).once

    updater.perform!
  end
end
