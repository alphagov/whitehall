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
    edition = build(:draft_edition, body: "")
    assert_not edition.valid?

    updater = DraftEditionUpdater.new(edition)
    updater.expects(:notify!).never
    updater.expects(:update_publishing_api!).never

    updater.perform!
  end

  # This is used to allow saving of partial content on Editions.
  # Given a Tab containing only fields X, Y and Z, we should be
  # able to save edits to those fields, even if fields A, B and C
  # on another tab are invalid.
  test "can perform if edition `skip_can_perform_check` is passed and the edition is otherwise invalid" do
    edition = build(:draft_edition, body: "")
    assert_not edition.valid?

    updater = DraftEditionUpdater.new(edition)
    updater.expects(:notify!).once
    updater.expects(:update_publishing_api!).once

    updater.perform!(skip_can_perform_check: true)
  end

  test "cannot perform if edition is not draft" do
    edition = create(:published_edition)
    updater = DraftEditionUpdater.new(edition)
    updater.expects(:notify!).never
    updater.expects(:update_publishing_api!).never

    updater.perform!
  end

  test "updates editions that cannot be tagged to organisations" do
    organisation = create(:organisation)
    edition = create(:draft_corporate_information_page, organisation:, access_limiting: "organisations", access_limiting_organisation_ids: [organisation.id])
    updater = DraftEditionUpdater.new(edition, { current_user: create(:user, organisation:) })
    updater.expects(:update_publishing_api!).once
    updater.expects(:notify!).once

    updater.perform!
  end
end
