require 'test_helper'

class AssetManagerAttachmentMetadataUpdateWorkerTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  let(:subject) { AssetManagerAttachmentMetadataUpdateWorker.new }
  let(:attachment_data) { FactoryBot.create(:attachment_data) }

  let(:mock_access_limited_worker) { mock('access_limited_worker') }
  let(:mock_delete_worker) { mock('delete_worker') }
  let(:mock_draft_status_update_worker) { mock('draft_status_update_worker') }
  let(:mock_link_header_update_worker) { mock('link_header_update_worker') }
  let(:mock_redirect_url_update_worker) { mock('redirect_url_update_worker') }
  let(:mock_replacement_id_update_worker) { mock('replacement_id_update_worker') }

  setup do
    mock_access_limited_worker.stubs(:perform)
    mock_delete_worker.stubs(:perform)
    mock_draft_status_update_worker.stubs(:perform)
    mock_link_header_update_worker.stubs(:perform)
    mock_redirect_url_update_worker.stubs(:perform)
    mock_replacement_id_update_worker.stubs(:perform)

    AssetManagerAttachmentAccessLimitedWorker.stubs(:new).returns(mock_access_limited_worker)
    AssetManagerAttachmentDeleteWorker.stubs(:new).returns(mock_delete_worker)
    AssetManagerAttachmentDraftStatusUpdateWorker.stubs(:new).returns(mock_draft_status_update_worker)
    AssetManagerAttachmentLinkHeaderUpdateWorker.stubs(:new).returns(mock_link_header_update_worker)
    AssetManagerAttachmentRedirectUrlUpdateWorker.stubs(:new).returns(mock_redirect_url_update_worker)
    AssetManagerAttachmentReplacementIdUpdateWorker.stubs(:new).returns(mock_replacement_id_update_worker)
  end

  test 'it uses the asset_migration queue' do
    assert_equal 'asset_migration', subject.class.queue
  end

  test 'calls AssetManagerAttachmentAccessLimitedWorker#perform with the attachment_data id' do
    mock_access_limited_worker.expects(:perform).with(attachment_data.id)
    subject.perform(attachment_data.id)
  end

  test 'calls AssetManagerAttachmentDeleteWorker#perform with the attachment_data id' do
    mock_delete_worker.expects(:perform).with(attachment_data.id)
    subject.perform(attachment_data.id)
  end

  test 'calls AssetManagerAttachmentDeleteWorker last' do
    assert_equal AssetManagerAttachmentDeleteWorker, subject.workers.last
  end

  test 'calls AssetManagerAttachmentDraftStatusUpdateWorker#perform with the attachment_data id' do
    mock_draft_status_update_worker.expects(:perform).with(attachment_data.id)
    subject.perform(attachment_data.id)
  end

  test 'calls AssetManagerAttachmentLinkHeaderUpdateWorker#perform with the attachment_data id' do
    mock_link_header_update_worker.expects(:perform).with(attachment_data.id)
    subject.perform(attachment_data.id)
  end

  test 'calls AssetManagerAttachmentRedirectUrlUpdateWorker#perform with the attachment_data id' do
    mock_redirect_url_update_worker.expects(:perform).with(attachment_data.id)
    subject.perform(attachment_data.id)
  end

  test 'calls AssetManagerAttachmentReplacementIdUpdateWorker#perform with the attachment_data id' do
    mock_replacement_id_update_worker.expects(:perform).with(attachment_data.id)
    subject.perform(attachment_data.id)
  end
end
