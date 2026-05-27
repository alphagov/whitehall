require "test_helper"

class PublishAttachmentAssetJobTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  describe PublishAttachmentAssetJob do
    let(:asset_manager_id) { attachment_data.assets.first.asset_manager_id }
    let(:job) { PublishAttachmentAssetJob.new }

    context "attachment was created on the latest edition" do
      let(:attachable) { create(:published_publication, title: "news-title") }
      let(:attachment_data) { create(:attachment_data, attachable:) }
      let(:attachment) { create(:file_attachment, attachable:, attachment_data: attachment_data) }

      before do
        attachment_data.attachments = [attachment]
        attachment_data.save!
      end

      it "it deletes and updates the asset if attachment data is deleted" do
        attachment.destroy!

        AssetManager::AssetDeleter.expects(:call).with(asset_manager_id)
        AssetManager::AssetUpdater.expects(:call).with(asset_manager_id, { "draft" => false, "parent_document_url" => "https://www.test.gov.uk/government/publications/news-title" })

        job.perform(attachment_data.id)
      end

      it "updates the asset if attachment data is not deleted" do
        AssetManager::AssetUpdater.expects(:call).with(asset_manager_id, { "draft" => false, "parent_document_url" => "https://www.test.gov.uk/government/publications/news-title" })

        job.perform(attachment_data.id)
      end
    end

    context "attachment was created on the previous edition" do
      let(:previous_attachable) { create(:superseded_publication) }
      let(:previous_attachment) { create(:attachment, attachable: previous_attachable, attachment_data:) }
      let(:attachable) { create(:published_publication, document: previous_attachable.document) }
      let(:attachment_data) { create(:attachment_data, attachable:) }
      let(:attachment) { create(:file_attachment, attachable:, attachment_data:) }

      before do
        attachment_data.attachments = [previous_attachment, attachment]
        attachment_data.save!
      end

      it "it deletes the asset if attachment data is deleted" do
        attachment.destroy!

        AssetManager::AssetDeleter.expects(:call).with(asset_manager_id)

        job.perform(attachment_data.id)
      end

      it "does not update the asset" do
        AssetManager::AssetUpdater.expects(:call).never

        job.perform(attachment_data.id)
      end
    end

    context "attachment belongs to a consultation outcome" do
      let(:consultation) { create(:published_consultation, title: "my-consultation") }
      let(:outcome) { create(:consultation_outcome, :with_file_attachment, consultation:) }
      let(:attachment_data) { outcome.attachments.first.attachment_data }

      it "updates the asset with the parent consultation's public URL" do
        AssetManager::AssetUpdater.expects(:call).with(
          asset_manager_id,
          { "draft" => false, "parent_document_url" => "https://www.test.gov.uk/government/consultations/my-consultation" },
        )

        job.perform(attachment_data.id)
      end
    end

    context "attachment belongs to a consultation public feedback" do
      let(:consultation) { create(:published_consultation, title: "my-consultation") }
      let(:public_feedback) { create(:consultation_public_feedback, :with_file_attachment, consultation:) }
      let(:attachment_data) { public_feedback.attachments.first.attachment_data }

      it "updates the asset with the parent consultation's public URL" do
        AssetManager::AssetUpdater.expects(:call).with(
          asset_manager_id,
          { "draft" => false, "parent_document_url" => "https://www.test.gov.uk/government/consultations/my-consultation" },
        )

        job.perform(attachment_data.id)
      end
    end

    context "attachment belongs to a call for evidence outcome" do
      let(:call_for_evidence) { create(:published_call_for_evidence, title: "my-call-for-evidence") }
      let(:outcome) { create(:call_for_evidence_outcome, :with_file_attachment, call_for_evidence:) }
      let(:attachment_data) { outcome.attachments.first.attachment_data }

      it "updates the asset with the parent call for evidence's public URL" do
        AssetManager::AssetUpdater.expects(:call).with(
          asset_manager_id,
          { "draft" => false, "parent_document_url" => "https://www.test.gov.uk/government/calls-for-evidence/my-call-for-evidence" },
        )

        job.perform(attachment_data.id)
      end
    end
  end
end
