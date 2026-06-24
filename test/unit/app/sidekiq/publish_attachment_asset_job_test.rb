require "test_helper"

class PublishAttachmentAssetJobTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  asset_data_types = ApplicationRecord
    .descendants
    .select { |klass| klass.include?(AssetData) }
    .map(&:name)

  asset_data_types.each do |asset_data_type|
    describe PublishAttachmentAssetJob do
      context "with #{asset_data_type}" do
        let(:job) { PublishAttachmentAssetJob.new }

        context "attachment was created on the latest edition" do
          let(:attachment_data) { build(asset_data_type.underscore.to_sym) }

          let(:attachable) do
            create(:published_consultation, title: "news-title")
          end

          let(:attachment) do
            case asset_data_type
            when "AttachmentData"
              attachment_data.attachable = attachable
              create(:file_attachment, attachable:, attachment_data:)
            when "ImageData"
              create(:image, edition: attachable, image_data: attachment_data)
            end
          end

          before do
            attachment.save!
            attachable.save!
            attachment_data.save!
          end

          it "it deletes and updates the asset if attachment data is deleted" do
            attachment.destroy!

            attachment_data.assets.each do |asset|
              AssetManager::AssetDeleter.expects(:call).with(asset.asset_manager_id)
              AssetManager::AssetUpdater.expects(:call).with(asset.asset_manager_id, { "draft" => false, "parent_document_url" => "https://www.test.gov.uk/government/consultations/news-title" })
            end

            job.perform(attachment_data.id, asset_data_type)
          end

          it "updates the asset if attachment data is not deleted" do
            attachment_data.assets.each do |asset|
              AssetManager::AssetUpdater.expects(:call).with(asset.asset_manager_id, { "draft" => false, "parent_document_url" => "https://www.test.gov.uk/government/consultations/news-title" })
            end

            job.perform(attachment_data.id, asset_data_type)
          end
        end

        context "attachment was created on the previous edition" do
          let(:attachment_data) { build(asset_data_type.underscore.to_sym) }
          let(:previous_attachable) { create(:superseded_consultation) }
          let(:attachable) { create(:published_consultation, document: previous_attachable.document) }

          let(:previous_attachment) do
            case asset_data_type
            when "AttachmentData"
              attachment_data.attachable = previous_attachable
              create(:file_attachment, attachable: previous_attachable, attachment_data:)
            when "ImageData"
              create(:image, edition: previous_attachable, image_data: attachment_data)
            end
          end

          let(:attachment) do
            case asset_data_type
            when "AttachmentData"
              attachment_data.attachable = previous_attachable
              create(:file_attachment, attachable:, attachment_data:)
            when "ImageData"
              create(:image, edition: attachable, image_data: attachment_data)
            end
          end

          before do
            case asset_data_type
            when "AttachmentData"
              attachment_data.attachments = [previous_attachment, attachment]
            when "ImageData"
              attachment_data.images = [previous_attachment, attachment]
            end

            attachment_data.save!
          end

          it "it deletes the asset if attachment data is deleted" do
            attachment.destroy!

            attachment_data.assets.each do |asset|
              AssetManager::AssetDeleter.expects(:call).with(asset.asset_manager_id)
            end

            job.perform(attachment_data.id, asset_data_type)
          end

          it "does not update the asset" do
            AssetManager::AssetUpdater.expects(:call).never

            job.perform(attachment_data.id, asset_data_type)
          end
        end
      end

      context "attachment belongs to" do
        let(:asset_manager_id) { attachment_data.assets.first.asset_manager_id }
        let(:job) { PublishAttachmentAssetJob.new }

        context "a consultation outcome" do
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

        context "a consultation public feedback" do
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

        context "a call for evidence outcome" do
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
  end
end
