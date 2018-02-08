require "test_helper"

class HmrcAssetsControllerTest < ActionController::TestCase
  test "does not redirect hmrc asset requests that aren't made via the asset host" do
    hmrc_asset_directory = File.join(Whitehall.clean_uploads_root, 'uploaded', 'hmrc')
    asset_filesystem_path = File.join(hmrc_asset_directory, 'asset.txt')
    FileUtils.makedirs(hmrc_asset_directory)
    FileUtils.touch(asset_filesystem_path)

    request.host = 'not-asset-host.com'

    get :show, params: { path: 'asset', format: 'txt' }

    assert_response 200
  end
end
