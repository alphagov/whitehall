require "test_helper"

module ServiceListeners
  class AttachmentAssetDeleterTest < ActiveSupport::TestCase
    extend Minitest::Spec::DSL

    describe ServiceListeners::AttachmentAssetDeleter do
      let(:edition) { create(:draft_news_article) }
      let(:first_attachment) { create(:file_attachment, attachable: edition, attachment_data: create(:attachment_data, attachable: edition)) }
      let(:second_attachment) { create(:file_attachment, attachable: edition, attachment_data: create(:attachment_data, attachable: edition)) }

      before do
        stub_asset(first_attachment.attachment_data.assets.first.asset_manager_id)
        stub_asset(second_attachment.attachment_data.assets.first.asset_manager_id)
      end

      it "calls deleter for all assets of all attachments" do
        edition.delete!
        edition.delete_all_attachments

        AssetManager::AssetDeleter.expects(:call).with(first_attachment.attachment_data.assets.first.asset_manager_id)
        AssetManager::AssetDeleter.expects(:call).with(second_attachment.attachment_data.assets.first.asset_manager_id)

        ServiceListeners::AttachmentAssetDeleter.call(edition)
        DeleteAttachmentAssetJob.drain
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
