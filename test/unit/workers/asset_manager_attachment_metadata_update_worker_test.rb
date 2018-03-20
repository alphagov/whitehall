require 'test_helper'

class AssetManagerAttachmentMetadataUpdateWorkerTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  let(:subject) { AssetManagerAttachmentMetadataUpdateWorker.new }
  let(:attachment_data) { FactoryBot.create(:attachment_data) }

  test 'it uses the asset_migration queue' do
    assert_equal 'asset_migration', subject.class.queue
  end

  test 'queues a job on the AssetManagerAttachmentMetadataUpdateWorker' do
    AssetManagerAttachmentAccessLimitedWorker.expects(:perform_async).with(attachment_data.id)
    subject.perform(attachment_data.id)
  end

  test 'queues a job on the AssetManagerAttachmentDeleteWorker' do
    AssetManagerAttachmentDeleteWorker.expects(:perform_async).with(attachment_data.id)
    subject.perform(attachment_data.id)
  end

  test 'queues a job on the AssetManagerAttachmentDraftStatusUpdateWorker' do
    AssetManagerAttachmentDraftStatusUpdateWorker.expects(:perform_async).with(attachment_data.id)
    subject.perform(attachment_data.id)
  end

  test 'queues a job on the AssetManagerAttachmentLinkHeaderUpdateWorker' do
    AssetManagerAttachmentLinkHeaderUpdateWorker.expects(:perform_async).with(attachment_data.id)
    subject.perform(attachment_data.id)
  end

  test 'queues a job on the AssetManagerAttachmentRedirectUrlUpdateWorker' do
    AssetManagerAttachmentRedirectUrlUpdateWorker.expects(:perform_async).with(attachment_data.id)
    subject.perform(attachment_data.id)
  end

  test 'queues a job on the AssetManagerAttachmentReplacementIdUpdateWorker' do
    AssetManagerAttachmentReplacementIdUpdateWorker.expects(:perform_async).with(attachment_data.id)
    subject.perform(attachment_data.id)
  end
end
