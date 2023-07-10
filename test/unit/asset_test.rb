require "test_helper"

class AssetTest < ActiveSupport::TestCase
  setup do
    @attachment_data = build(:attachment_data)
    @variant = Asset.variants[:original]
  end

  test "should be invalid without an asset_manager_id" do
    asset = Asset.new(attachment_data: @attachment_data, variant: @variant)

    assert_not asset.valid?
  end

  test "should be invalid without an attachment_data" do
    asset = Asset.new(asset_manager_id: "asset_manager_id", variant: @variant)

    assert_not asset.valid?
  end

  test "should be invalid without a variant" do
    asset = Asset.new(asset_manager_id: "asset_manager_id", attachment_data: @attachment_data)

    assert_not asset.valid?
  end

  test "should be valid if all fields present" do
    asset = Asset.new(attachment_data: @attachment_data, asset_manager_id: "asset_manager_id", variant: @variant)

    assert asset.valid?
  end
end
