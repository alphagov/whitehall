require "test_helper"

class AssetTest < ActiveSupport::TestCase
  setup do
    @attachment_data = build(:attachment_data)
    @variant = Asset.variants[:original]
  end

  test "should be invalid without an asset_manager_id" do
    asset = Asset.new(assetable: @attachment_data, variant: @variant)

    assert_not asset.valid?
    assert_equal asset.errors.messages[:asset_manager_id], ["can't be blank"]
  end

  test "should be invalid without an assetable" do
    asset = Asset.new(asset_manager_id: "asset_manager_id", variant: @variant)

    assert_not asset.valid?
    assert_equal asset.errors.messages[:assetable], ["can't be blank"]
  end

  test "should be invalid without a variant" do
    asset = Asset.new(asset_manager_id: "asset_manager_id", assetable: @attachment_data)

    assert_not asset.valid?
    assert_equal asset.errors.messages[:variant], ["can't be blank"]
  end

  test "should be valid if all fields present" do
    asset = Asset.new(assetable: @attachment_data, asset_manager_id: "asset_manager_id", variant: @variant)

    assert asset.valid?
  end
end
