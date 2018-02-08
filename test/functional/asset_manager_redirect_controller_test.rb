require "test_helper"

class AssetManagerRedirectControllerTest < ActionController::TestCase
  setup do
    Plek.any_instance.stubs(:public_asset_host).returns('http://asset-host.com')
  end

  test "redirects all asset requests to the asset host" do
    get :show, params: { path: 'asset', format: 'txt' }

    assert_redirected_to 'http://asset-host.com/government/uploads/asset.txt'
  end
end
