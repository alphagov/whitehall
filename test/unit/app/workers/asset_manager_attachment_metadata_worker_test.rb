require "test_helper"

class AssetManagerAttachmentMetadataWorkerTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  describe AssetManagerAttachmentMetadataWorker do
    let(:attachment_data) { create(:attachment_data) }
    let(:worker) { AssetManagerAttachmentMetadataWorker.new }

    it "calls both updater and deleter" do
      AssetManager::AttachmentUpdater.expects(:call).with(attachment_data)

      AssetManager::AttachmentDeleter.expects(:call).with(
        attachment_data,
      )

      worker.perform(attachment_data.id)
    end

    context "attachment data has missing assets" do
      let(:attachment_data) { create(:attachment_data_with_no_assets) }

      it "does not call updater" do
        AssetManager::AttachmentUpdater.expects(:call).never

        worker.perform(attachment_data.id)
      end

      it "calls deleter" do
        AssetManager::AttachmentDeleter.expects(:call)

        worker.perform(attachment_data.id)
      end
    end
  end
end
