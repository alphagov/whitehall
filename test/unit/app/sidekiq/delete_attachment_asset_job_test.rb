require "test_helper"

class DeleteAttachmentAssetJobTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  describe DeleteAttachmentAssetJob do
    let(:attachable) { create(:draft_edition) }
    let(:attachment_data) { create(:attachment_data, attachable:) }
    let(:asset_manager_id) { attachment_data.assets.first.asset_manager_id }
    let(:job) { DeleteAttachmentAssetJob.new }

    it "deletes the asset" do
      AssetManager::AssetDeleter.expects(:call).with(asset_manager_id)
      Logger.any_instance.stubs(:info).with("Asset #{@asset_manager_id} has already been deleted from Asset Manager")

      job.perform(attachment_data.id)
    end

    it "raises an error if the asset deletion fails for an unknown reason" do
      expected_error = GdsApi::HTTPServerError.new(500)
      AssetManager::AssetDeleter.expects(:call).raises(expected_error)

      assert_raises(GdsApi::HTTPServerError) { job.perform(attachment_data.id) }
    end
  end
end
