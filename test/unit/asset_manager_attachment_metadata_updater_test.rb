require 'test_helper'

class AssetManagerAttachmentMetadataUpdaterTest < ActiveSupport::TestCase
  test 'uses find_each with the range specified' do
    AttachmentData.expects(:find_each).with(start: 1, finish: 2)

    AssetManagerAttachmentMetadataUpdater.update_range(1, 2)
  end

  [
    AssetManagerAttachmentAccessLimitedWorker,
    AssetManagerAttachmentDeleteWorker,
    AssetManagerAttachmentDraftStatusUpdateWorker,
    AssetManagerAttachmentLinkHeaderUpdateWorker,
    AssetManagerAttachmentRedirectUrlUpdateWorker,
    AssetManagerAttachmentReplacementIdUpdateWorker
  ].each do |worker|
    test "queues a job on the #{worker}" do
      attachment_data = FactoryBot.create(:attachment_data)
      worker.expects(:perform_async).with(attachment_data.id)
      AssetManagerAttachmentMetadataUpdater.update_range(attachment_data.id, attachment_data.id)
    end
  end
end
