require "test_helper"
require "whitehall/asset_manager_storage"

class Whitehall::AssetManagerStorage::FileTest < ActiveSupport::TestCase
  setup do
    @asset_path = "path/to/asset.png"
    @asset_manager_id = "asset_manager_id_original"
    model = build(:image_data)
    model.id = 1
    model.assets = []
    model.assets << build(:asset, asset_manager_id: @asset_manager_id, variant: Asset.variants[:original], filename: "asset.png")
    @file = Whitehall::AssetManagerStorage::File.new(@asset_path, model)
    Plek.stubs(:new).returns(stub("plek", asset_root: "http://assets-host"))
  end

  test "returns the local store path as the path" do
    # Carrierwave needs this for its hooks
    assert_equal @asset_path, @file.path
  end

  test "queues the call to delete the asset from asset manager" do
    AssetManagerDeleteAssetWorker.expects(:perform_async).with(@asset_manager_id)

    @file.delete
  end

  test "#content_type returns the first element of the content type array" do
    assert_equal "image/png", @file.content_type
  end

  test "when the asset_path contains non-ascii characters it percent-encodes" do
    asset_path = "path/to/ässet.png"
    model = ImageData.new
    model.id = 1
    model.assets << build(:asset, asset_manager_id: @asset_manager_id, variant: Asset.variants[:original], filename: "ässet.png")

    file = Whitehall::AssetManagerStorage::File.new(asset_path, model)

    assert_equal "http://assets-host/media/#{@asset_manager_id}/%C3%A4sset.png", file.url
  end

  test "constructs the url of the file using the assets root, media, asset_manager_id and filename" do
    expected_asset_url = URI.join("http://assets-host", "/media/", "#{@asset_manager_id}/", @file.filename).to_s

    assert_equal expected_asset_url, @file.url
  end

  test "returns file url using asset_manager_id when the model has the original asset" do
    model = build(:attachment_data_with_asset, attachable: build(:draft_edition, id: 1))
    model.save!
    model.reload

    assert_equal "http://assets-host/media/asset_manager_id/sample.docx", model.file.url
  end

  test "returns file url using asset_manager_id when the model has an asset variant" do
    model = build(:attachment_data, attachable: build(:draft_edition, id: 1))
    model.save!
    model.reload

    assert_equal "http://assets-host/media/asset_manager_id_thumbnail/thumbnail_greenpaper.pdf.png", model.file.url(:thumbnail)
  end

  test "returns nil when the model has assets but the requested variant is not available" do
    model = build(:attachment_data_with_asset, attachable: build(:draft_edition, id: 1))
    model.save!
    model.reload

    assert_nil model.file.url(:thumbnail)
  end

  test "returns store path when the model has no assets, although it should (still uploading or error has occurred)" do
    model = build(:attachment_data_with_no_assets, attachable: build(:draft_edition, id: 1))
    model.save!
    model.reload

    assert_equal model.file.path, model.file.url
  end
end
