require "test_helper"

class AssetManagerAttachmentMetadataWorkerTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  describe AssetManagerAttachmentMetadataWorker do
    let(:edition) { create(:draft_publication) }
    let(:attachment_data) { create(:attachment_data, attachable: edition) }
    let(:worker) { AssetManagerAttachmentMetadataWorker.new }

    it "calls updater" do
      AssetManager::AttachmentUpdater.expects(:call).with(attachment_data)

      worker.perform(attachment_data.id)
    end

    context "attachment data has missing assets" do
      let(:attachment_data) { create(:attachment_data_with_no_assets, attachable: edition) }

      it "does not call updater" do
        AssetManager::AttachmentUpdater.expects(:call).never

        worker.perform(attachment_data.id)
      end
    end
  end
end
