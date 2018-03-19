require 'test_helper'

class AssetManagerAttachmentMetadataUpdateWorkerTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  let(:subject) { AssetManagerAttachmentMetadataUpdateWorker.new }

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
      subject.perform(attachment_data.id)
    end

    test "queues a job on the #{worker}" do
      worker.expects(:perform_async).with(attachment_data.id)
      subject.perform(attachment_data.id)
    end
  end
end
