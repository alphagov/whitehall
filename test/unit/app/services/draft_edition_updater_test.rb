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
    edition = create(:draft_publication, access_limiting: "organisations", organisations: [create(:organisation)])
    updater = DraftEditionUpdater.new(edition, { current_user: create(:user, organisation: create(:organisation)) })
    updater.expects(:notify!).never
    updater.expects(:update_publishing_api!).never

    updater.perform!
  end
  test "cannot perform if user is limiting their own access via access_limiting_organisations when flag is on" do
    @feature_flags.switch!(:access_limiting_organisations_ui, true)

    other_org = create(:organisation)
    edition = create(:draft_publication, access_limiting: "organisations", access_limiting_organisation_ids: [other_org.id])
    updater = DraftEditionUpdater.new(edition, { current_user: create(:user, organisation: create(:organisation)) })
    updater.expects(:notify!).never
    updater.expects(:update_publishing_api!).never

    updater.perform!
  end

  test "cannot perform when access_limiting is organisations but no orgs are set when flag is on" do
    edition = create(:draft_publication, access_limiting: "organisations")

    @feature_flags.switch!(:access_limiting_organisations_ui, true)

    updater = DraftEditionUpdater.new(edition, { current_user: create(:user, organisation: create(:organisation)) })
    updater.expects(:notify!).never
    updater.expects(:update_publishing_api!).never

    updater.perform!
  end

  test "can perform when the current user's organisation is in access_limiting_organisations when flag is on" do
    @feature_flags.switch!(:access_limiting_organisations_ui, true)

    organisation = create(:organisation)
    edition = create(:draft_publication, access_limiting: "organisations", access_limiting_organisation_ids: [organisation.id])
    updater = DraftEditionUpdater.new(edition, { current_user: create(:user, organisation:) })
    updater.expects(:update_publishing_api!).once
    updater.expects(:notify!).once

    updater.perform!
  end

  test "updates editions that cannot be tagged to organisations" do
    organisation = create(:organisation)
    edition = create(:draft_corporate_information_page, organisation:, access_limiting: "organisations")
    updater = DraftEditionUpdater.new(edition, { current_user: create(:user, organisation:) })
    updater.expects(:update_publishing_api!).once
    updater.expects(:notify!).once

    updater.perform!
  end
end
