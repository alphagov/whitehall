require "test_helper"

class AssetManager::AssetDeleterTest < ActiveSupport::TestCase
  setup do
    @asset_id = "asset-id"
    @asset_url = "http://asset-manager/assets/#{@asset_id}"
    @legacy_url_path = "legacy-url-path"
    @worker = AssetManager::AssetDeleter.new
  end

  test "deletes file from asset manager" do
    @worker.stubs(:find_asset_by).with(@legacy_url_path)
      .returns("id" => @asset_id)
    Services.asset_manager.expects(:delete_asset).with(@asset_id)

    @worker.call(@legacy_url_path)
  end

  test "does not attempt a delete if the asset is already deleted" do
    @worker.stubs(:find_asset_by).with(@legacy_url_path).returns(
      "id" => @asset_id,
      "deleted" => true,
    )
    Services.asset_manager.expects(:delete_asset).never

    @worker.call(@legacy_url_path)
  end
end
