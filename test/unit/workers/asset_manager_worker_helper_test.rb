require 'test_helper'

class AssetManagerWorkerHelperTest < ActiveSupport::TestCase
  setup do
    @asset_id = 'asset-id'
    @asset_url = "http://asset-manager/assets/#{@asset_id}"
    @legacy_url_path = 'legacy-url-path'
    @worker = Object.new
    @worker.extend(AssetManagerWorkerHelper)
  end

  test 'returns attributes including asset ID' do
    Services.asset_manager.stubs(:whitehall_asset).with(@legacy_url_path)
      .returns(gds_api_response('id' => @asset_url))

    attributes = @worker.send(:find_asset_by, @legacy_url_path)

    assert_equal @asset_id, attributes['id']
  end

  test 'returns attributes including asset URL' do
    Services.asset_manager.stubs(:whitehall_asset).with(@legacy_url_path)
      .returns(gds_api_response('id' => @asset_url))

    attributes = @worker.send(:find_asset_by, @legacy_url_path)

    assert_equal @asset_url, attributes['url']
  end

  test 'returns other attributes' do
    Services.asset_manager.stubs(:whitehall_asset).with(@legacy_url_path)
      .returns(gds_api_response('id' => @asset_url, 'key' => 'value'))

    attributes = @worker.send(:find_asset_by, @legacy_url_path)

    assert_equal 'value', attributes['key']
  end

private

  def gds_api_response(attributes = {})
    http_response = stub('http_response', body: attributes.to_json)
    GdsApi::Response.new(http_response)
  end
end
