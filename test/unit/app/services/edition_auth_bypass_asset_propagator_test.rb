require "test_helper"

class EditionAuthBypassAssetPropagatorTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  describe "#propagate" do
    test "updates file attachments with the edition's auth_bypass_id" do
      edition = create(:draft_edition)
      file_attachment = create(:file_attachment, attachable: edition)
      expected_attributes = { "auth_bypass_ids" => [edition.auth_bypass_id] }

      AssetManagerUpdateAssetJob.expects(:perform_async_in_queue).with(
        "asset_manager_updater",
        "AttachmentData",
        file_attachment.attachment_data.id,
        expected_attributes,
      )

      EditionAuthBypassAssetPropagator.new(edition).propagate
    end

    test "sends empty auth_bypass_ids when the edition has no token" do
      edition = create(:draft_edition)
      file_attachment = create(:file_attachment, attachable: edition)
      edition.auth_bypass_id = nil
      expected_attributes = { "auth_bypass_ids" => [] }

      AssetManagerUpdateAssetJob.expects(:perform_async_in_queue).with(
        "asset_manager_updater",
        "AttachmentData",
        file_attachment.attachment_data.id,
        expected_attributes,
      )

      EditionAuthBypassAssetPropagator.new(edition).propagate
    end

    test "updates images with the edition's auth_bypass_id" do
      edition = create(:draft_fatality_notice)
      image = create(:image, edition:)
      expected_attributes = { "auth_bypass_ids" => [edition.auth_bypass_id] }

      AssetManagerUpdateAssetJob.expects(:perform_async_in_queue).with(
        "asset_manager_updater",
        "ImageData",
        image.image_data.id,
        expected_attributes,
      )

      EditionAuthBypassAssetPropagator.new(edition).propagate
    end

    test "does not attempt to update html attachments" do
      edition = create(:draft_edition)
      create(:html_attachment, attachable: edition)

      AssetManagerUpdateAssetJob.expects(:perform_async_in_queue).never

      EditionAuthBypassAssetPropagator.new(edition).propagate
    end

    test "updates a consultation response form asset" do
      edition = create(:consultation)
      participation = create(:consultation_participation, consultation: edition)
      consultation_response_form = create(:consultation_response_form, consultation_participation: participation)

      edition.reload
      expected_attributes = { "auth_bypass_ids" => [edition.auth_bypass_id] }

      AssetManagerUpdateAssetJob.expects(:perform_async_in_queue).with(
        "asset_manager_updater",
        "ConsultationResponseFormData",
        consultation_response_form.consultation_response_form_data.id,
        expected_attributes,
      )

      EditionAuthBypassAssetPropagator.new(edition).propagate
    end

    test "updates a consultation outcome's attachments" do
      edition = create(:draft_consultation)
      outcome = create(:consultation_outcome, consultation: edition)
      file_attachment = create(:file_attachment, attachable: outcome)
      expected_attributes = { "auth_bypass_ids" => [edition.auth_bypass_id] }

      AssetManagerUpdateAssetJob.expects(:perform_async_in_queue).with(
        "asset_manager_updater",
        "AttachmentData",
        file_attachment.attachment_data.id,
        expected_attributes,
      )

      EditionAuthBypassAssetPropagator.new(edition).propagate
    end

    test "updates a consultation's public feedback attachments" do
      edition = create(:draft_consultation)
      feedback = create(:consultation_public_feedback, consultation: edition)
      file_attachment = create(:file_attachment, attachable: feedback)
      expected_attributes = { "auth_bypass_ids" => [edition.auth_bypass_id] }

      AssetManagerUpdateAssetJob.expects(:perform_async_in_queue).with(
        "asset_manager_updater",
        "AttachmentData",
        file_attachment.attachment_data.id,
        expected_attributes,
      )

      EditionAuthBypassAssetPropagator.new(edition).propagate
    end

    test "updates a call for evidence response form asset" do
      edition = create(:call_for_evidence)
      participation = create(:call_for_evidence_participation, call_for_evidence: edition)
      call_for_evidence_response_form = create(:call_for_evidence_response_form, call_for_evidence_participation: participation)

      edition.reload
      expected_attributes = { "auth_bypass_ids" => [edition.auth_bypass_id] }

      AssetManagerUpdateAssetJob.expects(:perform_async_in_queue).with(
        "asset_manager_updater",
        "CallForEvidenceResponseFormData",
        call_for_evidence_response_form.call_for_evidence_response_form_data.id,
        expected_attributes,
      )

      EditionAuthBypassAssetPropagator.new(edition).propagate
    end

    test "updates a call for evidence outcome's attachments" do
      edition = create(:draft_call_for_evidence)
      outcome = create(:call_for_evidence_outcome, call_for_evidence: edition)
      file_attachment = create(:file_attachment, attachable: outcome)
      expected_attributes = { "auth_bypass_ids" => [edition.auth_bypass_id] }

      AssetManagerUpdateAssetJob.expects(:perform_async_in_queue).with(
        "asset_manager_updater",
        "AttachmentData",
        file_attachment.attachment_data.id,
        expected_attributes,
      )

      EditionAuthBypassAssetPropagator.new(edition).propagate
    end
  end
end
