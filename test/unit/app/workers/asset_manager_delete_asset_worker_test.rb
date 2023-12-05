require "test_helper"

class AssetManagerDeleteAssetWorkerTest < ActiveSupport::TestCase
  setup do
    @asset = create(:image_data).assets.first
    @asset_manager_id = @asset.asset_manager_id
    @worker = AssetManagerDeleteAssetWorker.new
  end

  test "it calls AssetManager::AssetDeleter" do
    AssetManager::AssetDeleter.expects(:call).with("/government/legacy-url-path", "any-asset-id")

    @worker.perform("/government/legacy-url-path", "any-asset-id")
  end

  test "it raises an error if the asset deletion fails for an unknown reason" do
    expected_error = GdsApi::HTTPServerError.new(500)
    AssetManager::AssetDeleter.expects(:call).raises(expected_error)

    assert_raises(GdsApi::HTTPServerError) { @worker.perform(nil, @asset_manager_id) }
  end

  test "it deletes the Asset from Asset table" do
    AssetManager::AssetDeleter.stubs(:call)

    @worker.perform(nil, @asset_manager_id)

    assert_not Asset.where(asset_manager_id: @asset_manager_id).exists?
  end

  test "it deletes the Asset from Asset table even if the asset is not found in Asset Manager" do
    expected_error = AssetManager::ServiceHelper::AssetNotFound.new(@asset_manager_id)
    AssetManager::AssetDeleter.expects(:call).raises(expected_error)
    Logger.any_instance.stubs(:info).with("Asset #{@asset_manager_id} has already been deleted from Asset Manager")

    @worker.perform(nil, @asset_manager_id)

    assert_not Asset.where(asset_manager_id: @asset_manager_id).exists?
  end

  test "it deletes the Asset from Asset table with asset manager id as first param " do
    AssetManager::AssetDeleter.stubs(:call)

    @worker.perform(@asset_manager_id)

    assert_not Asset.where(asset_manager_id: @asset_manager_id).exists?
  end
end
