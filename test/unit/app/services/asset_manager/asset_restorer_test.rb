require "test_helper"

class AssetManager::AssetRestorerTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  setup do
    @asset_manager_id = "asset-id"
    @job = AssetManager::AssetRestorer.new
  end

  describe "called with asset_manager_id" do
    test "restores the asset if it is deleted" do
      @job.stubs(:find_asset_by_id).with(@asset_manager_id).returns(
        "id" => @asset_manager_id,
        "deleted" => true,
      )

      Services.asset_manager.expects(:restore_asset).with(@asset_manager_id)

      @job.call(@asset_manager_id)
    end

    test "does not attempt a restore if the asset is not deleted" do
      @job.stubs(:find_asset_by_id).with(@asset_manager_id)
             .returns("id" => @asset_manager_id)

      Services.asset_manager.expects(:restore_asset).never

      @job.call(@asset_manager_id)
    end
  end
end
