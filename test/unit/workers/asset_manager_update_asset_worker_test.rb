require 'test_helper'

class AssetManagerUpdateAssetWorkerTest < ActiveSupport::TestCase
  setup do
    @asset_id = 'asset-id'
    @asset_url = "http://asset-manager/assets/#{@asset_id}"
    @legacy_url_path = 'legacy-url-path'
    @worker = AssetManagerUpdateAssetWorker.new
  end

  test 'marks draft asset as published' do
    Services.asset_manager.stubs(:whitehall_asset).with(@legacy_url_path)
      .returns('id' => @asset_url, 'draft' => true)
    Services.asset_manager.expects(:update_asset).with(@asset_id, 'draft' => false)

    @worker.perform(@legacy_url_path, 'draft' => false)
  end

  test 'does not mark asset as published if already published' do
    Services.asset_manager.stubs(:whitehall_asset).with(@legacy_url_path)
      .returns('id' => @asset_url, 'draft' => false)
    Services.asset_manager.expects(:update_asset).never

    @worker.perform(@legacy_url_path, 'draft' => false)
  end

  test 'mark published asset as draft' do
    Services.asset_manager.stubs(:whitehall_asset).with(@legacy_url_path)
      .returns('id' => @asset_url, 'draft' => false)
    Services.asset_manager.expects(:update_asset).with(@asset_id, 'draft' => true)

    @worker.perform(@legacy_url_path, 'draft' => true)
  end

  test 'does not mark asset as draft if already draft' do
    Services.asset_manager.stubs(:whitehall_asset).with(@legacy_url_path)
      .returns('id' => @asset_url, 'draft' => true)
    Services.asset_manager.expects(:update_asset).never

    @worker.perform(@legacy_url_path, 'draft' => true)
  end
end
