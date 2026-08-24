require "test_helper"
require "attachment_test_helper"

class AssetManagerAttachmentMetadataJobTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  describe AssetManagerAttachmentMetadataJob do
    for_each_asset_data_type do |asset_data_type|
      let(:edition) { create(:draft_publication) }
      let(:job) { AssetManagerAttachmentMetadataJob.new }

      context "attachment data has assets" do
        let(:attachment_data) { build(asset_data_type.underscore.to_sym) }
        let(:attachment) { create_attachment(attachment_data:, edition:) }

        it "calls updater" do
          attachment.save!
          AssetManager::AttachmentUpdater.expects(:call).with(attachment.send(asset_data_type.underscore.to_sym))
          job.perform(attachment.send(asset_data_type.underscore.to_sym).id, asset_data_type)
        end
      end

      context "attachment data has missing assets" do
        let(:attachment_data) do
          attachment_data = build(asset_data_type.underscore.to_sym)
          attachment_data.assets.each(&:destroy!)
          attachment_data
        end
        let(:attachment) { create_attachment(attachment_data:, edition:) }

        it "does not call updater" do
          attachment.save!
          AssetManager::AttachmentUpdater.expects(:call).never
          job.perform(attachment.send(asset_data_type.underscore.to_sym).id, asset_data_type)
        end
      end
    end
  end
end
