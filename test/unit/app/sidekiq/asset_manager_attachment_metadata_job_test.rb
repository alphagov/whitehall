require "test_helper"

class AssetManagerAttachmentMetadataJobTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  describe AssetManagerAttachmentMetadataJob do
    let(:edition) { create(:draft_publication) }
    let(:attachment_data) { create(:attachment_data, attachable: edition) }
    let(:job) { AssetManagerAttachmentMetadataJob.new }

    it "calls updater" do
      AssetManager::AttachmentUpdater.expects(:call).with(attachment_data)

      job.perform(attachment_data.id)
    end

    context "attachment data has missing assets" do
      let(:attachment_data) { create(:attachment_data_with_no_assets, attachable: edition) }

      it "does not call updater" do
        AssetManager::AttachmentUpdater.expects(:call).never

        job.perform(attachment_data.id)
      end
    end
  end
end
