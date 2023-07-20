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
  end
end
