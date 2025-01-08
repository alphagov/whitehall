require "test_helper"

class AssetTest < ActiveSupport::TestCase
  setup do
    @image_data = create(:image_data_with_no_assets)
    @variant = Asset.variants[:original]
  end

  test "should be invalid without an asset_manager_id" do
    asset = Asset.new(assetable: @image_data, variant: @variant)

    assert_not asset.valid?
    assert_equal asset.errors.messages[:asset_manager_id], ["cannot be blank"]
  end

  test "should be invalid without an assetable" do
    asset = Asset.new(asset_manager_id: "asset_manager_id", variant: @variant)

    assert_not asset.valid?
    assert_equal asset.errors.messages[:assetable], ["cannot be blank"]
  end

  test "should be invalid without a variant" do
    asset = Asset.new(asset_manager_id: "asset_manager_id", assetable: @image_data)

    assert_not asset.valid?
    assert_equal asset.errors.messages[:variant], ["cannot be blank"]
  end

  test "should be valid if all fields present" do
    asset = Asset.new(assetable: @image_data, asset_manager_id: "asset_manager_id", variant: @variant, filename: "greenpaper.pdf")

    assert asset.valid?
  end

  test "should not save if variant is duplicated regarding to assetable" do
    Asset.create!(assetable: @image_data, asset_manager_id: "asset_manager_id", variant: @variant, filename: "greenpaper.pdf")
    asset = Asset.new(assetable: @image_data, asset_manager_id: "asset_manager_id_2", variant: @variant, filename: "greenpaper.pdf")

    assert_not asset.valid?
  end

  test "should allow updating an asset" do
    asset = Asset.create!(assetable: @image_data, asset_manager_id: "asset_manager_id", variant: @variant, filename: "greenpaper.pdf")
    asset.filename = "not-greepaper.pdf"

    assert asset.valid?
  end
end
