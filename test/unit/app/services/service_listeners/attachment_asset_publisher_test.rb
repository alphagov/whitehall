require "test_helper"

module ServiceListeners
  class AttachmentAssetPublisherTest < ActiveSupport::TestCase
    extend Minitest::Spec::DSL

    describe ServiceListeners::AttachmentAssetPublisher do
      let(:edition) { create(:published_news_article) }
      let(:attachment) { create(:file_attachment, attachable: edition, attachment_data: create(:attachment_data, attachable: edition)) }

      it "sets the expected attributes" do
        expected_attribute_hash = {
          "draft" => false,
          "parent_document_url" => edition.public_url(draft: false),
        }

        AssetManager::AssetUpdater.expects(:call).with(attachment.attachment_data.assets.first.asset_manager_id, expected_attribute_hash)

        ServiceListeners::AttachmentAssetPublisher.call(edition)
        PublishAttachmentAssetJob.drain
      end

      it "deletes the asset if the attachment is deleted" do
        stub_asset(attachment.attachment_data.assets.first.asset_manager_id)
        attachment.destroy!

        AssetManager::AssetDeleter.expects(:call).with(attachment.attachment_data.assets.first.asset_manager_id)

        ServiceListeners::AttachmentAssetPublisher.call(edition)
        PublishAttachmentAssetJob.drain
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
