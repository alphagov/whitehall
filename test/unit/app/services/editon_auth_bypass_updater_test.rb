require "test_helper"

class EditionAuthBypassUpdaterTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  describe "#call" do
    let(:user) { create(:user) }
    let(:updater) { Minitest::Mock.new }
    let(:uid) { SecureRandom.uuid }

    before do
      updater.expect :perform!, true
    end

    test "updates the editions auth_bypass_id, saves it with the current user and calls 'perform!' on the updater" do
      edition = create(:draft_edition)
      auth_bypass_id_to_revoke = edition.auth_bypass_id
      SecureRandom.stubs(uuid: uid)

      EditionAuthBypassUpdater.new(edition:, current_user: user, updater:).call

      assert_equal uid, edition.auth_bypass_id
      assert_not_equal auth_bypass_id_to_revoke, edition.auth_bypass_id
      assert_equal user, edition.edition_authors.last.user
    end

    test "propagates the new auth_bypass_id to attached assets" do
      SecureRandom.stubs(uuid: uid)
      edition = create(:draft_edition)
      file_attachment = create(:file_attachment, attachable: edition)

      AssetManagerUpdateAssetJob.expects(:perform_async_in_queue).with(
        "asset_manager_updater",
        "AttachmentData",
        file_attachment.attachment_data.id,
        { "auth_bypass_ids" => [uid] },
      )

      EditionAuthBypassUpdater.new(edition:, current_user: user, updater:).call
    end
  end
end
