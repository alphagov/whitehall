require "test_helper"

class PublishAttachmentAssetJobTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  describe PublishAttachmentAssetJob do
    let(:attachable) { create(:draft_news_article) }
    let(:attachment_data) { create(:attachment_data, attachable:) }
    let(:asset_manager_id) { attachment_data.assets.first.asset_manager_id }
    let(:worker) { PublishAttachmentAssetJob.new }

    it "it deletes and updates the asset if attachment data is deleted" do
      attachment = create(:file_attachment, attachable: attachable, attachment_data: attachment_data)
      attachment.destroy!

      AssetManager::AssetDeleter.expects(:call).with(asset_manager_id)
      AssetManager::AssetUpdater.expects(:call).with(asset_manager_id, { "draft" => false, "parent_document_url" => attachment_data.attachable_url })

      worker.perform(attachment_data.id)
    end

    it "only updates the asset if attachment data is not deleted" do
      AssetManager::AssetUpdater.expects(:call).with(asset_manager_id, { "draft" => false, "parent_document_url" => attachment_data.attachable_url })

      worker.perform(attachment_data.id)
    end

    context "attachment data is replaced" do
      it "does not set the parent_document_url" do
        attachment_data.update!(replaced_by: create(:attachment_data, attachable:))

        AssetManager::AssetUpdater.expects(:call).with(asset_manager_id, { "draft" => false })

        worker.perform(attachment_data.id)
      end
    end
  end
end
