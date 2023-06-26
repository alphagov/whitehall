require "test_helper"

class AssetTest < ActiveSupport::TestCase
  setup do
    @attachment_data = build(:attachment_data)
    @version = Asset.versions[:original]
  end

  test "should be invalid without an asset_manager_id" do
    asset = Asset.new(attachment_data: @attachment_data, version: @version)

    assert_not asset.valid?
  end

  test "should be invalid without an attachment_data" do
    asset = Asset.new(asset_manager_id: "asset_manager_id", version: @version)

    assert_not asset.valid?
  end

  test "should be invalid without a version" do
    asset = Asset.new(asset_manager_id: "asset_manager_id", attachment_data: @attachment_data)

    assert_not asset.valid?
  end

  test "should be valid if all fields present" do
    asset = Asset.new(attachment_data: @attachment_data, asset_manager_id: "asset_manager_id", version: @version)

    assert asset.valid?
  end
end
