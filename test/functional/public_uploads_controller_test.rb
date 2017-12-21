require "test_helper"

class PublicUploadsControllerTest < ActionController::TestCase
  setup do
    Plek.any_instance.stubs(:public_asset_host).returns('http://asset-host.com')
  end

  test "redirects asset requests that aren't made via the asset host" do
    request.host = 'not-asset-host.com'

    get :show, params: { path: 'asset', format: 'txt' }

    assert_redirected_to 'http://asset-host.com/government/uploads/asset.txt'
  end

  test 'does not redirect asset requests that are made via the asset host' do
    asset_filesystem_path = File.join(Whitehall.clean_uploads_root, 'asset.txt')
    FileUtils.makedirs(Whitehall.clean_uploads_root)
    FileUtils.touch(asset_filesystem_path)

    request.host = 'asset-host.com'

    get :show, params: { path: 'asset', format: 'txt' }

    assert_response 200
  end

  test "does not redirect hmrc asset requests that aren't made via the asset host" do
    hmrc_asset_directory = File.join(Whitehall.clean_uploads_root, 'uploaded', 'hmrc')
    asset_filesystem_path = File.join(hmrc_asset_directory, 'asset.txt')
    FileUtils.makedirs(hmrc_asset_directory)
    FileUtils.touch(asset_filesystem_path)

    request.host = 'not-asset-host.com'

    get :show, params: { path: 'uploaded/hmrc/asset', format: 'txt' }

    assert_response 200
  end
end
