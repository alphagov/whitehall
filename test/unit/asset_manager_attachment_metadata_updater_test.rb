require 'test_helper'

class AssetManagerAttachmentMetadataUpdaterTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  let(:attachment_data) { FactoryBot.create(:attachment_data) }

  setup do
    VirusScanHelpers.simulate_virus_scan(attachment_data.file)
  end

  test 'uses find_each with the range specified' do
    AttachmentData.expects(:find_each).with(start: 1, finish: 2)

    AssetManagerAttachmentMetadataUpdater.update_range(1, 2)
  end

  test "calls the worker if the file exists" do
    AssetManagerAttachmentMetadataUpdateWorker.expects(:perform_async).with(attachment_data.id)

    AssetManagerAttachmentMetadataUpdater.update_range(attachment_data.id, attachment_data.id)
  end

  test "does not call the worker if the file doesn't exist" do
    FileUtils.rm(attachment_data.reload.file.path)
    AssetManagerAttachmentMetadataUpdateWorker.expects(:perform_async).never

    AssetManagerAttachmentMetadataUpdater.update_range(attachment_data.id, attachment_data.id)
  end
end
