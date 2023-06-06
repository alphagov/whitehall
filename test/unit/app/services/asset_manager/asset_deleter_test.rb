require "test_helper"

class AssetManager::AssetDeleterTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  setup do
    @asset_manager_id = "asset-id"
    @legacy_url_path = "legacy-url-path"
    @worker = AssetManager::AssetDeleter.new
  end

  describe "called with legacy_url_path" do
    test "deletes file from asset manager" do
      @worker.stubs(:find_asset_by).with(@legacy_url_path)
             .returns("id" => @asset_manager_id)
      Services.asset_manager.expects(:delete_asset).with(@asset_manager_id)

      @worker.call(@legacy_url_path, nil)
    end

    test "does not attempt a delete if the asset is already deleted" do
      @worker.stubs(:find_asset_by).with(@legacy_url_path).returns(
        "id" => @asset_manager_id,
        "deleted" => true,
      )
      Services.asset_manager.expects(:delete_asset).never

      @worker.call(@legacy_url_path, nil)
    end
  end

  describe "called with asset_manager_id" do
    test "deletes file from asset manager" do
      @worker.stubs(:find_asset_by_id).with(@asset_manager_id)
             .returns("id" => @asset_manager_id)

      Services.asset_manager.expects(:delete_asset).with(@asset_manager_id)

      @worker.call(nil, @asset_manager_id)
    end

    test "does not attempt a delete if the asset is already deleted" do
      @worker.stubs(:find_asset_by_id).with(@asset_manager_id).returns(
        "id" => @asset_manager_id,
        "deleted" => true,
      )

      Services.asset_manager.expects(:delete_asset).never

      @worker.call(nil, @asset_manager_id)
    end
  end
end
