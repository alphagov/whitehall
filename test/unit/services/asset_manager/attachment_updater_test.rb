require "test_helper"

class AssetManager::AttachmentUpdaterTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  describe AssetManager::AttachmentUpdater do
    let(:subject) { AssetManager::AttachmentUpdater }
    let(:file) { File.open(fixture_path.join("sample.rtf")) }
    let(:attachment) { FactoryBot.create(:file_attachment, file:) }
    let(:attachment_data) { attachment.attachment_data }

    it "groups updates together" do
      AssetManager::AssetUpdater.expects(:call).once

      subject.call(attachment_data, redirect_url: true, draft_status: true)
    end

    context "when the attachment has been deleted" do
      before do
        attachment.delete
      end

      it "does not update the asset" do
        AssetManager::AssetUpdater.expects(:call).never

        subject.call(attachment_data, redirect_url: true, draft_status: true)
      end
    end
  end
end
