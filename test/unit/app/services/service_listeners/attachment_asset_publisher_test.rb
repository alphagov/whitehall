require "test_helper"
require "attachment_test_helper"

module ServiceListeners
  class AttachmentAssetPublisherTest < ActiveSupport::TestCase
    extend Minitest::Spec::DSL

    describe ServiceListeners::AttachmentAssetPublisher do
      for_each_asset_data_type do |asset_data_type|
        describe "for #{asset_data_type}" do
          let(:edition) { create(:published_publication) }
          let(:attachment_data) { build(asset_data_type.underscore.to_sym) }
          let(:attachment) { create_attachment(attachment_data:, edition:) }

          it "sets the expected attributes" do
            expected_attribute_hash = {
              "draft" => false,
              "access_limited_organisation_ids" => [],
              "access_limited_user_ids" => [],
              "auth_bypass_ids" => [],
              "parent_document_url" => edition.public_url(draft: false),
            }

            attachment.send(asset_data_type.underscore.to_sym).assets.each do |asset|
              AssetManager::AssetUpdater.expects(:call).with(asset.asset_manager_id, expected_attribute_hash)
            end

            ServiceListeners::AttachmentAssetPublisher.call(edition)
            PublishAttachmentAssetJob.drain
          end

          it "deletes the asset if the attachment is deleted" do
            attachment.send(asset_data_type.underscore.to_sym).assets.each do |asset|
              stub_asset(asset.asset_manager_id)
            end

            attachment.destroy!

            attachment.send(asset_data_type.underscore.to_sym).assets.each do |asset|
              AssetManager::AssetDeleter.expects(:call).with(asset.asset_manager_id)
            end

            ServiceListeners::AttachmentAssetPublisher.call(edition)
            PublishAttachmentAssetJob.drain
          end
        end
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
