require 'test_helper'

class AssetManagerDeleteAssetWorkerTest < ActiveSupport::TestCase
  test 'deletes file from asset manager' do
    json_response = {
      id: 'http://asset-manager/assets/asset-id'
    }.to_json
    http_response = stub('http_response', body: json_response)
    gds_api_response = GdsApi::Response.new(http_response)
    Services.asset_manager.stubs(:whitehall_asset).with('/government/uploads/path/to/asset.png').returns(gds_api_response)
    Services.asset_manager.expects(:delete_asset).with('asset-id')

    worker = AssetManagerDeleteAssetWorker.new
    worker.perform('/government/uploads/path/to/asset.png')
  end
end
