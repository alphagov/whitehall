require 'test_helper'

class AssetManagerAttachmentMetadataUpdaterTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

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
    let(:attachment_data) { FactoryBot.create(:attachment_data) }

    test "sets the #{worker} queue to 'asset_migration'" do
      worker.expects(:set).with(queue: 'asset_migration').returns(worker)
      AssetManagerAttachmentMetadataUpdater.update_range(attachment_data.id, attachment_data.id)
    end

    test "queues a job on the #{worker}" do
      worker.expects(:perform_async).with(attachment_data.id)
      AssetManagerAttachmentMetadataUpdater.update_range(attachment_data.id, attachment_data.id)
    end
  end
end
