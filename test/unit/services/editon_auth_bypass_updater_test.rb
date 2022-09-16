require "test_helper"

class EditionAuthBypassUpdaterTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  describe "#call" do
    let(:user) { create(:user) }
    let(:updater) { MiniTest::Mock.new }
    let(:uid) { SecureRandom.uuid }

    before do
      updater.expect :perform!, true
    end

    test "updates the editions auth_bypass_id, saves it with the current user and calls 'perform!' on the updater" do
      edition = create(:draft_edition)
      auth_bypass_id_to_revoke = edition.auth_bypass_id
      SecureRandom.stubs(uuid: uid)

      service = EditionAuthBypassUpdater.new(
        edition:,
        current_user: user,
        updater:,
      )

      service.call

      assert_equal edition.auth_bypass_id, uid
      assert_not_equal edition.auth_bypass_id, auth_bypass_id_to_revoke
      assert_equal edition.edition_authors.last.user, user
    end

    test "updates attachments with auth_bypass_ids" do
      edition = create(:draft_edition)
      file_attachment = create(:file_attachment, attachable: edition)

      SecureRandom.stubs(uuid: uid)
      expected_attributes = { auth_bypass_ids: [uid] }

      service = EditionAuthBypassUpdater.new(
        edition:,
        current_user: user,
        updater:,
      )

      AssetManagerUpdateWhitehallAssetWorker.expects(:perform_async_in_queue).with(
        "asset_manager_updater",
        file_attachment.attachment_data.to_global_id,
        expected_attributes,
      )

      service.call
    end

    test "updates an image with auth_bypass_id" do
      edition = create(:draft_case_study)
      image = create(:image, edition:)

      SecureRandom.stubs(uuid: uid)
      expected_attributes = { auth_bypass_ids: [uid] }

      service = EditionAuthBypassUpdater.new(
        edition:,
        current_user: user,
        updater:,
      )

      AssetManagerUpdateWhitehallAssetWorker.expects(:perform_async_in_queue).with(
        "asset_manager_updater",
        image.image_data.to_global_id,
        expected_attributes,
      )

      service.call
    end

    test "does not attempt to update html attachments via the update whitehall asset worker" do
      edition = create(:draft_edition)
      create(:html_attachment, attachable: edition)

      SecureRandom.stubs(uuid: uid)

      service = EditionAuthBypassUpdater.new(
        edition:,
        current_user: user,
        updater:,
      )

      AssetManagerUpdateWhitehallAssetWorker.expects(:perform_async_in_queue).never

      service.call
    end

    test "updates a consultation response form asset with auth_bypass_id" do
      edition = create(:consultation)
      participation = create(:consultation_participation, consultation: edition)
      consultation_response_form = create(:consultation_response_form, consultation_participation: participation)

      SecureRandom.stubs(uuid: uid)
      expected_attributes = { auth_bypass_ids: [uid] }

      service = EditionAuthBypassUpdater.new(
        edition:,
        current_user: user,
        updater:,
      )

      AssetManagerUpdateWhitehallAssetWorker.expects(:perform_async_in_queue).with(
        "asset_manager_updater",
        consultation_response_form.consultation_response_form_data.to_global_id,
        expected_attributes,
      )

      service.call
    end

    test "updates a consultation outcome's attachments with auth_bypass_id" do
      edition = create(:draft_consultation)
      outcome = create(:consultation_outcome, consultation: edition)
      file_attachment = create(:file_attachment, attachable: outcome)

      SecureRandom.stubs(uuid: uid)
      expected_attributes = { auth_bypass_ids: [uid] }

      service = EditionAuthBypassUpdater.new(
        edition:,
        current_user: user,
        updater:,
      )

      AssetManagerUpdateWhitehallAssetWorker.expects(:perform_async_in_queue).with(
        "asset_manager_updater",
        file_attachment.attachment_data.to_global_id,
        expected_attributes,
      )

      service.call
    end

    test "updates a consultation's public feedback attachments with auth_bypass_id" do
      edition = create(:draft_consultation)
      feedback = create(:consultation_public_feedback, consultation: edition)
      file_attachment = create(:file_attachment, attachable: feedback)

      SecureRandom.stubs(uuid: uid)
      expected_attributes = { auth_bypass_ids: [uid] }

      service = EditionAuthBypassUpdater.new(
        edition:,
        current_user: user,
        updater:,
      )

      AssetManagerUpdateWhitehallAssetWorker.expects(:perform_async_in_queue).with(
        "asset_manager_updater",
        file_attachment.attachment_data.to_global_id,
        expected_attributes,
      )

      service.call
    end
  end
end
