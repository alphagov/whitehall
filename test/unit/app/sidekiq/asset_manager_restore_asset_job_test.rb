require "test_helper"

class AssetManagerRestoreAssetJobTest < ActiveSupport::TestCase
  setup do
    @job = AssetManagerRestoreAssetJob.new
  end

  test "it calls AssetManager::AssetRestorer with the redirect_url" do
    AssetManager::AssetRestorer.expects(:call).with("any-asset-id", "https://www.gov.uk/example")

    @job.perform("any-asset-id", "https://www.gov.uk/example")
  end

  test "it calls AssetManager::AssetRestorer with a nil redirect_url" do
    AssetManager::AssetRestorer.expects(:call).with("any-asset-id", nil)

    @job.perform("any-asset-id", nil)
  end

  test "it raises an error if the asset restore fails" do
    expected_error = GdsApi::HTTPServerError.new(500)
    AssetManager::AssetRestorer.expects(:call).raises(expected_error)

    assert_raises(GdsApi::HTTPServerError) { @job.perform("any-asset-id", nil) }
  end
end
