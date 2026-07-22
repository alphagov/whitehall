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
            if asset_data_type == "CallForEvidenceResponseFormData"
              create(:published_call_for_evidence, title: "news-title")
            else
              create(:published_consultation, title: "news-title")
            end
          end

          let(:attachment) do
            case asset_data_type
            when "AttachmentData"
              attachment_data.attachable = attachable
              create(:file_attachment, attachable:, attachment_data:)
            when "ImageData"
              create(:image, edition: attachable, image_data: attachment_data)
            when "ConsultationResponseFormData"
              create(:consultation_response_form, consultation_response_form_data: attachment_data)
            when "CallForEvidenceResponseFormData"
              create(:call_for_evidence_response_form, call_for_evidence_response_form_data: attachment_data)
            end
          end

          before do
            if asset_data_type == "ConsultationResponseFormData"
              attachable.consultation_participation = create(:consultation_participation, consultation_response_form: attachment)
            elsif asset_data_type == "CallForEvidenceResponseFormData"
              attachable.call_for_evidence_participation = create(:call_for_evidence_participation, call_for_evidence_response_form: attachment)
            end

            attachment.save!
            attachable.save!
            attachment_data.save!
          end

          it "it deletes and updates the asset if attachment data is deleted" do
            attachment.destroy!

            attachment_data.assets.each do |asset|
              AssetManager::AssetDeleter.expects(:call).with(asset.asset_manager_id)
              if asset_data_type == "ImageData"
                # there is no `parent_document_url` for `ImageData` as associated `Image` is hard deleted
                AssetManager::AssetUpdater.expects(:call).with(asset.asset_manager_id, { "draft" => false })
              else
                AssetManager::AssetUpdater.expects(:call).with(asset.asset_manager_id, { "draft" => false, "parent_document_url" => "https://www.test.gov.uk/government/consultations/news-title" })
              end
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

        # context "attachment was created on the previous edition" do
        #   let(:previous_attachable) { create(:superseded_consultation) }
        #   let(:previous_attachment) { create(:attachment, attachable: previous_attachable, attachment_data:) }
        #   let(:attachable) { create(:published_consultation, document: previous_attachable.document) }
        #   let(:attachment_data) { create(asset_data_type.underscore.to_sym) }
        #   let(:attachment) { create(:file_attachment, attachable:, attachment_data:) }

        #   before do
        #     attachment_data.attachments = [previous_attachment, attachment]
        #     attachment_data.save!
        #   end

        #   it "it deletes the asset if attachment data is deleted" do
        #     attachment.destroy!

        #     AssetManager::AssetDeleter.expects(:call).with(asset_manager_id)

        #     job.perform(attachment_data.id)
        #   end

        #   it "does not update the asset" do
        #     AssetManager::AssetUpdater.expects(:call).never

        #     job.perform(attachment_data.id)
        #   end
        # end

        # context "attachment belongs to a consultation outcome" do
        #   let(:consultation) { create(:published_consultation, title: "my-consultation") }
        #   let(:outcome) { create(:consultation_outcome, :with_file_attachment, consultation:) }
        #   let(:attachment_data) { outcome.attachments.first.attachment_data }

        #   it "updates the asset with the parent consultation's public URL" do
        #     AssetManager::AssetUpdater.expects(:call).with(
        #       asset_manager_id,
        #       { "draft" => false, "parent_document_url" => "https://www.test.gov.uk/government/consultations/my-consultation" },
        #     )

        #     job.perform(attachment_data.id)
        #   end
        # end

        # context "attachment belongs to a consultation public feedback" do
        #   let(:consultation) { create(:published_consultation, title: "my-consultation") }
        #   let(:public_feedback) { create(:consultation_public_feedback, :with_file_attachment, consultation:) }
        #   let(:attachment_data) { public_feedback.attachments.first.attachment_data }

        #   it "updates the asset with the parent consultation's public URL" do
        #     AssetManager::AssetUpdater.expects(:call).with(
        #       asset_manager_id,
        #       { "draft" => false, "parent_document_url" => "https://www.test.gov.uk/government/consultations/my-consultation" },
        #     )

        #     job.perform(attachment_data.id)
        #   end
        # end

        # context "attachment belongs to a call for evidence outcome" do
        #   let(:call_for_evidence) { create(:published_call_for_evidence, title: "my-call-for-evidence") }
        #   let(:outcome) { create(:call_for_evidence_outcome, :with_file_attachment, call_for_evidence:) }
        #   let(:attachment_data) { outcome.attachments.first.attachment_data }

        #   it "updates the asset with the parent call for evidence's public URL" do
        #     AssetManager::AssetUpdater.expects(:call).with(
        #       asset_manager_id,
        #       { "draft" => false, "parent_document_url" => "https://www.test.gov.uk/government/calls-for-evidence/my-call-for-evidence" },
        #     )

        #     job.perform(attachment_data.id)
        #   end
        # end
      end
    end
  end
end
