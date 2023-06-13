require "test_helper"

class AssetManagerAttachmentSetUploadedToWorkerTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  describe AssetManagerAttachmentSetUploadedToWorker do
    let(:publication) { create(:publication) }
    let(:attachment) { create(:file_attachment, attachable: publication) }
    let(:worker) { AssetManagerAttachmentSetUploadedToWorker.new }

    it "marks attachment as uploaded to Asset Manager" do
      AttachmentData.any_instance.expects(:uploaded_to_asset_manager!)

      worker.perform("Publication", publication.id, attachment.attachment_data.path)
    end

    it "doesn't mark the attachment as uploaded to Asset Manager if only the thumbnail is uploaded" do
      AttachmentData.any_instance.expects(:uploaded_to_asset_manager!).never

      worker.perform("Publication", publication.id, attachment.attachment_data.file.thumbnail.path)
    end

    it "raises an error if attachment isn't found" do
      assert_raises AssetManagerAttachmentSetUploadedToWorker::AttachmentDataNotFoundTransient do
        worker.perform("Publication", publication.id, "some-unknown-path")
      end
    end

    it "saves corresponding asset id for attachment" do
      asset_manager_id = "56fbf7e577550f39a5aea04a"
      asset = Asset.new(asset_manager_id:, attachment_data_id: attachment.attachment_data.id)
      Asset.stub(:new, asset) do
        worker.perform("Publication", publication.id, attachment.attachment_data.path, asset_manager_id)
        assert_equal Asset.where(asset_manager_id:).count, 1
      end
    end
  end
end
