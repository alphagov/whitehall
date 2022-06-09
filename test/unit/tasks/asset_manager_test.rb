require "test_helper"

class AssetManagerRake < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  teardown do
    task.reenable # without this, calling `invoke` does nothing after first test
  end

  describe "update_attachments_with_auth_bypass_ids" do
    let(:task) { Rake::Task["asset_manager:update_attachments_with_auth_bypass_ids"] }

    test "updates attachments with auth_bypass_ids when its latest edition is a draft" do
      edition = create(:draft_detailed_guide)
      file_attachment = create(:file_attachment, attachable: edition)
      expected_attributes = { auth_bypass_ids: [edition.auth_bypass_id] }

      AssetManagerUpdateWhitehallAssetWorker.expects(:perform_async_in_queue).with(
        "asset_manager_updater",
        file_attachment.attachment_data.to_global_id,
        expected_attributes,
      )

      task.invoke
    end

    test "does not update attachments with auth_bypass_ids when latest edition is not draft" do
      edition = create(:published_detailed_guide)
      create(:file_attachment, attachable: edition)

      AssetManagerUpdateWhitehallAssetWorker.expects(:perform_async_in_queue).never

      task.invoke
    end

    test "does not update attachments with auth_bypass_ids when latest edition is deleted" do
      edition = create(:deleted_detailed_guide)
      create(:file_attachment, attachable: edition)

      AssetManagerUpdateWhitehallAssetWorker.expects(:perform_async_in_queue).never

      task.invoke
    end

    test "does not attempt to update html attachments via the update whitehall asset worker" do
      edition = create(:draft_detailed_guide)
      create(:html_attachment, attachable: edition)

      AssetManagerUpdateWhitehallAssetWorker.expects(:perform_async_in_queue).never

      task.invoke
    end

    test "does not update attachments where the latest edition isn't draft" do
      document = create(:document)
      scheduled_edition = create(:scheduled_detailed_guide, document: document)
      published_edition = create(:published_detailed_guide, document: document)

      assert_equal published_edition, document.latest_edition

      create(:file_attachment, attachable: scheduled_edition)

      AssetManagerUpdateWhitehallAssetWorker.expects(:perform_async_in_queue).never

      task.invoke
    end

    test "skips over editions which do not have ability to have attachments" do
      create(:draft_fatality_notice)

      AssetManagerUpdateWhitehallAssetWorker.expects(:perform_async_in_queue).never

      task.invoke
    end
  end

  describe "update_consultation_response_forms_with_auth_bypass_ids" do
    let(:task) { Rake::Task["asset_manager:update_consultation_response_forms_with_auth_bypass_ids"] }

    test "updates a consultation response form asset with auth_bypass_id when it is part of the latest edition which is a draft" do
      edition = create(:consultation)
      participation = create(:consultation_participation, consultation: edition)
      consultation_response_form = create(:consultation_response_form, consultation_participation: participation)

      expected_attributes = { auth_bypass_ids: [edition.auth_bypass_id] }

      AssetManagerUpdateWhitehallAssetWorker.expects(:perform_async_in_queue).with(
        "asset_manager_updater",
        consultation_response_form.consultation_response_form_data.to_global_id,
        expected_attributes,
      )

      task.invoke
    end

    test "does not update attachments with auth_bypass_ids when latest edition is not draft" do
      edition = create(:published_consultation)
      participation = create(:consultation_participation, consultation: edition)
      create(:consultation_response_form, consultation_participation: participation)

      AssetManagerUpdateWhitehallAssetWorker.expects(:perform_async_in_queue).never

      task.invoke
    end

    test "does not update attachments with auth_bypass_ids when latest edition is deleted" do
      edition = create(:deleted_consultation)
      participation = create(:consultation_participation, consultation: edition)
      create(:consultation_response_form, consultation_participation: participation)

      AssetManagerUpdateWhitehallAssetWorker.expects(:perform_async_in_queue).never

      task.invoke
    end

    test "does not update attachments where the latest edition isn't draft" do
      document = create(:document)
      scheduled_edition = create(:scheduled_consultation, document: document)
      published_edition = create(:published_consultation, document: document)
      participation = create(:consultation_participation, consultation: scheduled_edition)
      create(:consultation_response_form, consultation_participation: participation)

      assert_equal published_edition, document.latest_edition

      AssetManagerUpdateWhitehallAssetWorker.expects(:perform_async_in_queue).never

      task.invoke
    end

    test "does not update auth bypass ids when no consultation response form exists" do
      document = create(:document)
      edition = create(:scheduled_consultation, document: document)
      create(:consultation_participation, consultation: edition)

      AssetManagerUpdateWhitehallAssetWorker.expects(:perform_async_in_queue).never

      task.invoke
    end

    test "does not update auth bypass ids when no consultation participation exists" do
      document = create(:document)
      create(:scheduled_consultation, document: document)

      AssetManagerUpdateWhitehallAssetWorker.expects(:perform_async_in_queue).never

      task.invoke
    end

    test "updates a consultation outcome's attachments with auth_bypass_id" do
      edition = create(:draft_consultation)
      outcome = create(:consultation_outcome, consultation: edition)
      file_attachment = create(:file_attachment, attachable: outcome)

      expected_attributes = { auth_bypass_ids: [edition.auth_bypass_id] }

      AssetManagerUpdateWhitehallAssetWorker.expects(:perform_async_in_queue).with(
        "asset_manager_updater",
        file_attachment.attachment_data.to_global_id,
        expected_attributes,
      )

      task.invoke
    end

    test "updates a consultation's public feedback attachments with auth_bypass_id" do
      edition = create(:draft_consultation)
      feedback = create(:consultation_public_feedback, consultation: edition)
      file_attachment = create(:file_attachment, attachable: feedback)

      expected_attributes = { auth_bypass_ids: [edition.auth_bypass_id] }

      AssetManagerUpdateWhitehallAssetWorker.expects(:perform_async_in_queue).with(
        "asset_manager_updater",
        file_attachment.attachment_data.to_global_id,
        expected_attributes,
      )

      task.invoke
    end
  end

  describe "update_consultation_response_forms_with_auth_bypass_ids" do
    let(:task) { Rake::Task["asset_manager:update_images_with_auth_bypass_ids"] }

    test "updates an image with auth_bypass_id when it is part of the latest edition which is a draft" do
      edition = create(:draft_case_study)
      image = create(:image, edition: edition)
      expected_attributes = { auth_bypass_ids: [edition.auth_bypass_id] }

      AssetManagerUpdateWhitehallAssetWorker.expects(:perform_async_in_queue).with(
        "asset_manager_updater",
        image.image_data.to_global_id,
        expected_attributes,
      )

      task.invoke
    end

    test "does not call the update worker when an edition has no images" do
      create(:draft_case_study)

      AssetManagerUpdateWhitehallAssetWorker.expects(:perform_async_in_queue).never

      task.invoke
    end

    test "does not update image with auth_bypass_ids when latest edition is not draft" do
      edition = create(:published_case_study)
      create(:image, edition: edition)

      AssetManagerUpdateWhitehallAssetWorker.expects(:perform_async_in_queue).never

      task.invoke
    end

    test "does not update image with auth_bypass_ids when latest edition is deleted" do
      edition = create(:deleted_case_study)
      create(:image, edition: edition)

      AssetManagerUpdateWhitehallAssetWorker.expects(:perform_async_in_queue).never

      task.invoke
    end

    test "does not update image where the latest edition isn't draft" do
      document = create(:document)
      scheduled_edition = create(:scheduled_case_study, document: document)
      published_edition = create(:published_case_study, document: document)

      assert_equal published_edition, document.latest_edition

      create(:image, edition: scheduled_edition)

      AssetManagerUpdateWhitehallAssetWorker.expects(:perform_async_in_queue).never

      task.invoke
    end
  end
end
