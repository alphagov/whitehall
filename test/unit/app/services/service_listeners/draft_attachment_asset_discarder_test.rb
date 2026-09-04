require "test_helper"
require "attachment_test_helper"

module ServiceListeners
  class DraftAttachmentAssetDiscarderTest < ActiveSupport::TestCase
    extend Minitest::Spec::DSL

    describe ServiceListeners::DraftAttachmentAssetDiscarder do
      describe "for all file attachments" do
        let(:edition) { create(:draft_edition) }
        let(:first_attachment) { create(:file_attachment, attachable: edition) }
        let(:second_attachment) { create(:csv_attachment, attachable: edition) }
        let!(:non_file_attachment) { create(:html_attachment, attachable: edition) }

        before do
          stub_asset(first_attachment.attachment_data.assets.first.asset_manager_id)
          stub_asset(second_attachment.attachment_data.assets.first.asset_manager_id)
        end

        it "calls deleter for all assets" do
          edition.delete!
          edition.delete_all_attachments

          AssetManager::AssetDeleter.expects(:call).with(first_attachment.attachment_data.assets.first.asset_manager_id)
          AssetManager::AssetDeleter.expects(:call).with(second_attachment.attachment_data.assets.first.asset_manager_id)

          ServiceListeners::DraftAttachmentAssetDiscarder.call(edition)
          DeleteAttachmentAssetJob.drain
        end
      end

      describe "for images" do
        let(:edition) { create(:draft_publication) }
        let(:attachment_data) { build(:image_data) }
        let(:image) { create_attachment(attachment_data:, edition:) }

        before do
          image.image_data.assets do |asset|
            stub_asset(asset.asset_manager_id)
          end
        end

        it "calls deleter for all assets" do
          image.edition.delete!

          image.image_data.assets.each do |asset|
            AssetManager::AssetDeleter.expects(:call).with(asset.asset_manager_id)
          end

          ServiceListeners::DraftAttachmentAssetDiscarder.call(edition)
          DeleteAttachmentAssetJob.drain
        end
      end

      describe "for consultation response form data" do
        let(:consultation) { create(:draft_consultation) }
        let(:response_form) { build(:consultation_response_form, consultation_participation: nil) }
        let(:participation) do
          create(:consultation_participation, consultation:, consultation_response_form: response_form)
        end
        let(:response_form_data) { response_form.consultation_response_form_data }

        before do
          participation
          consultation.reload
          response_form_data.assets.each { |asset| stub_asset(asset.asset_manager_id) }
        end

        it "calls deleter for all assets" do
          consultation.delete!

          response_form_data.assets.each do |asset|
            AssetManager::AssetDeleter.expects(:call).with(asset.asset_manager_id)
          end

          ServiceListeners::DraftAttachmentAssetDiscarder.call(consultation)
          DeleteAttachmentAssetJob.drain
        end
      end

      describe "for call for evidence response form data" do
        let(:call_for_evidence) { create(:draft_call_for_evidence) }
        let(:response_form) { build(:call_for_evidence_response_form, call_for_evidence_participation: nil) }
        let(:participation) do
          create(:call_for_evidence_participation, call_for_evidence:, call_for_evidence_response_form: response_form)
        end
        let(:response_form_data) { response_form.call_for_evidence_response_form_data }

        before do
          participation
          call_for_evidence.reload
          response_form_data.assets.each { |asset| stub_asset(asset.asset_manager_id) }
        end

        it "calls deleter for all assets" do
          call_for_evidence.delete!

          response_form_data.assets.each do |asset|
            AssetManager::AssetDeleter.expects(:call).with(asset.asset_manager_id)
          end

          ServiceListeners::DraftAttachmentAssetDiscarder.call(call_for_evidence)
          DeleteAttachmentAssetJob.drain
        end
      end

      def stub_asset(asset_manger_id, attributes = {})
        url_id = "http://asset-manager/assets/#{asset_manger_id}"
        Services.asset_manager.stubs(:asset)
                .with(asset_manger_id)
                .returns(attributes.merge(id: url_id).stringify_keys)
      end
    end
  end
end
