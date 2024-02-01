require "test_helper"

class PreviewableStorageTest < ActiveSupport::TestCase
  setup do
    @file = Tempfile.new("asset")
    FileUtils.mkdir_p(Whitehall.asset_manager_tmp_dir)
  end

  teardown do
    FileUtils.remove_dir(Whitehall.asset_manager_tmp_dir, true)
  end

  test "store! stores the file in asset manager and returns a asset manager file object" do
    image_data = create(:image_data)
    uploader = ImageUploader.new(image_data)

    storage = Storage::PreviewableStorage.new(uploader)
    file = CarrierWave::SanitizedFile.new(@file)

    AssetManagerCreateAssetWorker.expects(:perform_async).with do |actual_path, asset_params, auth_bypass_ids|
      uploaded_file_name = File.basename(@file.path)
      expected_path = %r{#{Whitehall.asset_manager_tmp_dir}/[a-z0-9-]+/#{uploaded_file_name}}

      expected_asset_params = { assetable_id: uploader.model.id, asset_variant: Asset.variants[:original], assetable_type: uploader.model.class.to_s }.deep_stringify_keys

      actual_path =~ expected_path && asset_params == expected_asset_params && auth_bypass_ids == image_data.auth_bypass_ids
    end

    result = storage.store!(file)

    assert result.filename.include? file.basename
  end

  test "retrieve! returns an asset manager file with the location of the file on disk" do
    image_data = create(:image_data)
    filename = "identifier.jpg"
    uploader = AttachmentUploader.new(image_data)
    storage = Storage::PreviewableStorage.new(uploader)

    file = storage.retrieve!(filename)

    assert_equal file.path, uploader.store_path(filename)
  end
end
