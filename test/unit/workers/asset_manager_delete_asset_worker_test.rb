require "test_helper"

class AssetManagerDeleteAssetWorkerTest < ActiveSupport::TestCase
  setup do
    @legacy_url_path = "legacy-url-path"
    @worker = AssetManagerDeleteAssetWorker.new
    @asset_manager_id = "asset_manager_id"
  end

  test "it calls AssetManager::AssetDeleter" do
    AssetManager::AssetDeleter.expects(:call).with(@legacy_url_path, @asset_manager_id)

    @worker.perform(@legacy_url_path, @asset_manager_id)
  end
end
