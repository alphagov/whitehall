require "test_helper"

class PublishAttachmentAssetJobTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  describe PublishAttachmentAssetJob do
    let(:asset_manager_id) { attachment_data.assets.first.asset_manager_id }
    let(:worker) { PublishAttachmentAssetJob.new }

    context "attachment was created on the latest edition" do
      let(:attachable) { create(:published_news_article, title: "news-title") }
      let(:attachment_data) { create(:attachment_data, attachable:) }
      let(:attachment) { create(:file_attachment, attachable:, attachment_data: attachment_data) }

      before do
        attachment_data.attachments = [attachment]
        attachment_data.save!
      end

      it "it deletes and updates the asset if attachment data is deleted" do
        attachment.destroy!

        AssetManager::AssetDeleter.expects(:call).with(asset_manager_id)
        AssetManager::AssetUpdater.expects(:call).with(asset_manager_id, { "draft" => false, "parent_document_url" => "https://www.test.gov.uk/government/news/news-title" })

        worker.perform(attachment_data.id)
      end

      it "updates the asset if attachment data is not deleted" do
        AssetManager::AssetUpdater.expects(:call).with(asset_manager_id, { "draft" => false, "parent_document_url" => "https://www.test.gov.uk/government/news/news-title" })

        worker.perform(attachment_data.id)
      end
    end

    context "attachment was created on the previous edition" do
      let(:previous_attachable) { create(:superseded_news_article) }
      let(:previous_attachment) { create(:attachment, attachable: previous_attachable, attachment_data:) }
      let(:attachable) { create(:published_news_article, document: previous_attachable.document) }
      let(:attachment_data) { create(:attachment_data, attachable:) }
      let(:attachment) { create(:file_attachment, attachable:, attachment_data:) }

      before do
        attachment_data.attachments = [previous_attachment, attachment]
        attachment_data.save!
      end

      it "it deletes the asset if attachment data is deleted" do
        attachment.destroy!

        AssetManager::AssetDeleter.expects(:call).with(asset_manager_id)

        worker.perform(attachment_data.id)
      end

      it "does not update the asset" do
        AssetManager::AssetUpdater.expects(:call).never

        worker.perform(attachment_data.id)
      end
    end
  end
end
