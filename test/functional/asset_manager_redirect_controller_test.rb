require "test_helper"

class AssetManagerRedirectControllerTest < ActionController::TestCase
  setup do
    Plek.any_instance.stubs(:public_asset_host).returns("http://asset-host.com")
    Plek.any_instance.stubs(:external_url_for).returns("http://draft-asset-host.com")
  end

  test "redirects asset requests made via public host to the public asset host" do
    request.host = "some-host.com"
    get :show, params: { path: "asset", format: "txt" }

    assert_redirected_to "http://asset-host.com/government/uploads/asset.txt"
  end

  test "redirects asset requests made via draft host to the draft asset host" do
    request.host = "draft-some-host.com"
    get :show, params: { path: "asset", format: "txt" }

    assert_redirected_to "http://draft-asset-host.com/government/uploads/asset.txt"
  end
end
