require "test_helper"

class EditionAuthBypassRevokerTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  describe "#call" do
    let(:user) { create(:user) }
    let(:updater) { Minitest::Mock.new }

    before do
      updater.expect :perform!, true
    end

    test "clears the edition's auth_bypass_id, saves it with the current user and calls 'perform!' on the updater" do
      edition = create(:draft_edition, :with_auth_bypass_id)
      assert_not_nil edition.auth_bypass_id

      EditionAuthBypassRevoker.new(edition:, current_user: user, updater:).call

      assert_nil edition.auth_bypass_id
      assert_equal user, edition.edition_authors.last.user
    end

    test "propagates the cleared auth_bypass_id to attached assets" do
      edition = create(:draft_edition)
      file_attachment = create(:file_attachment, attachable: edition)

      AssetManagerUpdateAssetJob.expects(:perform_async_in_queue).with(
        "asset_manager_updater",
        "AttachmentData",
        file_attachment.attachment_data.id,
        { "auth_bypass_ids" => [] },
      )

      EditionAuthBypassRevoker.new(edition:, current_user: user, updater:).call
    end
  end
end
