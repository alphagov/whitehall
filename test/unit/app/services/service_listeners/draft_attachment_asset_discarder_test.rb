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

      def stub_asset(asset_manger_id, attributes = {})
        url_id = "http://asset-manager/assets/#{asset_manger_id}"
        Services.asset_manager.stubs(:asset)
                .with(asset_manger_id)
                .returns(attributes.merge(id: url_id).stringify_keys)
      end
    end
  end
end
