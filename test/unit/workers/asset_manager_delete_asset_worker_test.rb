require "test_helper"

class AssetManagerDeleteAssetWorkerTest < ActiveSupport::TestCase
  setup do
    @legacy_url_path = "legacy-url-path"
    @worker = AssetManagerDeleteAssetWorker.new
  end

  test "it calls AssetManager::AssetDeleter" do
    AssetManager::AssetDeleter.expects(:call).with(@legacy_url_path)

    @worker.perform(@legacy_url_path)
  end
end
