require 'test_helper'

class AssetManagerAttachmentMetadataUpdateWorkerTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  let(:subject) { AssetManagerAttachmentMetadataUpdateWorker.new }

  test 'it uses the asset_migration queue' do
    assert_equal 'asset_migration', subject.class.queue
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

    test "queues a job on the #{worker}" do
      worker.expects(:perform_async).with(attachment_data.id)
      subject.perform(attachment_data.id)
    end
  end
end
