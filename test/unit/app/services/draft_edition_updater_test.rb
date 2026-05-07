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
    edition = create(:draft_publication, access_limited: :organisations, organisations: [create(:organisation)])
    updater = DraftEditionUpdater.new(edition, { current_user: create(:user, organisation: create(:organisation)) })
    updater.expects(:notify!).never
    updater.expects(:update_publishing_api!).never

    updater.perform!
  end

  test "can perform if edition uses named_users access limiting (skips org membership check)" do
    organisation = create(:organisation)
    user = create(:user, organisation:)
    other_organisation = create(:organisation)
    edition = create(:draft_publication, access_limited: :disabled, organisations: [other_organisation])
    edition.update!(access_limited: :named_users, access_limited_named_users: user.email)

    updater = DraftEditionUpdater.new(edition, { current_user: user })
    updater.expects(:update_publishing_api!).once
    updater.expects(:notify!).once

    updater.perform!
  end

  test "updates editions that cannot be tagged to organisations" do
    organisation = create(:organisation)
    edition = create(:draft_corporate_information_page, organisation:, access_limited: :organisations)
    updater = DraftEditionUpdater.new(edition, { current_user: create(:user, organisation:) })
    updater.expects(:update_publishing_api!).once
    updater.expects(:notify!).once

    updater.perform!
  end
end
