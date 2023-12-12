require "test_helper"
require "whitehall/asset_manager_storage"

class Whitehall::AssetManagerStorageTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  class AssetManagerUploader < CarrierWave::Uploader::Base
    attr_writer :assets_protected

    def assets_protected?
      @assets_protected
    end
  end

  setup do
    @file = Tempfile.new("asset")
    @uploader = AssetManagerUploader.new
    FileUtils.mkdir_p(Whitehall.asset_manager_tmp_dir)
  end

  teardown do
    FileUtils.remove_dir(Whitehall.asset_manager_tmp_dir, true)
  end

  test "store! returns an asset manager file" do
    featured_image_data = build(:featured_image_data)
    @uploader.stubs(:model).returns(featured_image_data)

    storage = Whitehall::AssetManagerStorage.new(@uploader)
    file = CarrierWave::SanitizedFile.new(@file)

    assert_equal Whitehall::AssetManagerStorage::File, storage.store!(file).class
  end

  test "instantiates an asset manager file with the location of the file on disk" do
    storage = Whitehall::AssetManagerStorage.new(@uploader)
    @uploader.stubs(:store_path).with("identifier").returns("asset-path")

    Whitehall::AssetManagerStorage::File.expects(:new).with("asset-path", nil, nil)

    storage.retrieve!("identifier")
  end

  test "retrieve! returns an asset manager file" do
    file = stub(:asset_manager_file)
    Whitehall::AssetManagerStorage::File.stubs(:new).returns(file)

    storage = Whitehall::AssetManagerStorage.new(@uploader)
    assert_equal file, storage.retrieve!("identifier")
  end

  context "uploader model is AttachmentData" do
    setup do
      model = build(:attachment_data)
      model.id = 1
      @uploader.stubs(:model).returns(model)
      @assetable_type = AttachmentData.name
    end

    test "creates a sidekiq job using the location of the file in the asset manager tmp directory" do
      AssetManagerCreateAssetWorker.expects(:perform_async).with do |actual_path, _|
        uploaded_file_name = File.basename(@file.path)
        expected_path = %r{#{Whitehall.asset_manager_tmp_dir}/[a-z0-9-]+/#{uploaded_file_name}}
        actual_path =~ expected_path
      end

      @uploader.store!(@file)
    end

    test "creates a sidekiq job and sets draft to true if the uploader's assets_protected? returns true" do
      @uploader.assets_protected = true

      AssetManagerCreateAssetWorker.expects(:perform_async).with(anything, anything, true, anything, anything, anything)

      @uploader.store!(@file)
    end

    test "creates a sidekiq job and sets draft to false if the uploader's assets_protected? returns false" do
      @uploader.assets_protected = false

      AssetManagerCreateAssetWorker.expects(:perform_async).with(anything, anything, false, anything, anything, anything)

      @uploader.store!(@file)
    end

    test "creates a sidekiq job and passes through the attachable class and id and auth_bypass_id if the model responds to attachable" do
      model = AttachmentData.new(attachable: Consultation.new(id: 1, auth_bypass_id: @auth_bypass_id))
      @uploader.stubs(:model).returns(model)

      AssetManagerCreateAssetWorker.expects(:perform_async).with(anything, anything, anything, "Consultation", 1, [@auth_bypass_id])

      @uploader.store!(@file)
    end

    test "calls worker with assetable and default original asset_variant" do
      variant = Asset.variants[:original]
      asset_args = { assetable_id: @uploader.model.id, asset_variant: variant, assetable_type: @assetable_type }.deep_stringify_keys

      AssetManagerCreateAssetWorker.expects(:perform_async).with(anything, asset_args, anything, anything, anything, anything)

      @uploader.store!(@file)
    end

    test "calls worker with assetable and variant" do
      variant = Asset.variants[:thumbnail]
      @uploader.stubs(:version_name).returns(:thumbnail)
      asset_args = { assetable_id: @uploader.model.id, asset_variant: variant, assetable_type: @assetable_type }.deep_stringify_keys

      AssetManagerCreateAssetWorker.expects(:perform_async).with(anything, asset_args, anything, anything, anything, anything)

      @uploader.store!(@file)
    end
  end

  context "uploader model is ImageData" do
    setup do
      @auth_bypass_id = "86385d6a-f918-4c93-96bf-087218a48ced"
      model = build(:image_data)
      model.id = 1
      model.stubs(:auth_bypass_ids).returns([@auth_bypass_id])
      @uploader.stubs(:model).returns(model)
      @assetable_type = ImageData.name
    end

    test "creates a sidekiq job and passes through the auth_bypass_id and no attachable class and id" do
      AssetManagerCreateAssetWorker.expects(:perform_async).with(anything, anything, anything, nil, nil, [@auth_bypass_id])

      @uploader.store!(@file)
    end

    test "calls worker with assetable and default original variant" do
      variant = Asset.variants[:original]
      asset_args = { assetable_id: @uploader.model.id, asset_variant: variant, assetable_type: @assetable_type }.deep_stringify_keys

      AssetManagerCreateAssetWorker.expects(:perform_async).with(anything, asset_args, anything, nil, nil, anything)

      @uploader.store!(@file)
    end

    test "calls worker with assetable and variant" do
      variant = Asset.variants[:s960]
      @uploader.stubs(:version_name).returns(:s960)
      asset_args = { assetable_id: @uploader.model.id, asset_variant: variant, assetable_type: @assetable_type }.deep_stringify_keys

      AssetManagerCreateAssetWorker.expects(:perform_async).with(anything, asset_args, anything, nil, nil, anything)

      @uploader.store!(@file)
    end

    test "should call deleteAssetWorker with asset manager id" do
      model = create(:image)

      AssetManagerDeleteAssetWorker.expects(:perform_async).times(7).with(regexp_matches(/asset_manager_id./))

      model.destroy!
    end
  end

  test "calls AssetManagerCreateAssetWorker when uploader is invoked for FeaturedImageData " do
    featured_image_data = build(:featured_image_data)
    @uploader.stubs(:model).returns(featured_image_data)
    asset_params = { assetable_id: featured_image_data.id, asset_variant: "original", assetable_type: "FeaturedImageData" }.deep_stringify_keys

    AssetManagerCreateAssetWorker.expects(:perform_async).once.with(anything, asset_params, nil, nil, nil, [])

    @uploader.store!(@file)
  end

  context "uploader model is ConsultationResponseFormData" do
    test "creates a sidekiq job and passes through the auth_bypass_id and no attachable class and id" do
      model = ConsultationResponseFormData.new
      model.stubs(:auth_bypass_ids).returns([@auth_bypass_id])
      @uploader.stubs(:model).returns(model)

      AssetManagerCreateAssetWorker.expects(:perform_async).with(anything, anything, anything, nil, nil, [@auth_bypass_id])

      @uploader.store!(@file)
    end
  end

  context "uploader model is CallForEvidenceResponseFormData" do
    test "creates a sidekiq job and passes through the auth_bypass_id and no attachable class and id" do
      model = CallForEvidenceResponseFormData.new
      model.stubs(:auth_bypass_ids).returns([@auth_bypass_id])
      @uploader.stubs(:model).returns(model)

      AssetManagerCreateAssetWorker.expects(:perform_async).with(anything, anything, anything, nil, nil, [@auth_bypass_id])

      @uploader.store!(@file)
    end
  end
end

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
    model = build(:attachment_data_with_asset)
    model.save!
    model.reload

    assert_equal "http://assets-host/media/asset_manager_id/sample.docx", model.file.url
  end

  test "returns file url using asset_manager_id when the model has an asset variant" do
    model = build(:attachment_data)
    model.save!
    model.reload

    assert_equal "http://assets-host/media/asset_manager_id_thumbnail/thumbnail_greenpaper.pdf.png", model.file.url(:thumbnail)
  end

  test "returns nil when the model has assets but the requested variant is not available" do
    model = build(:attachment_data_with_asset)
    model.save!
    model.reload

    assert_nil model.file.url(:thumbnail)
  end

  test "returns store path when the model has no assets, although it should (still uploading or error has occurred)" do
    model = build(:attachment_data_with_no_assets)
    model.save!
    model.reload

    assert_equal model.file.path, model.file.url
  end
end
