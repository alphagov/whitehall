require "test_helper"

class AssetManagerCreateAssetWorkerTest < ActiveSupport::TestCase
  setup do
    @file = Tempfile.new("asset", Dir.mktmpdir)
    @worker = AssetManagerCreateAssetWorker.new
    @asset_manager_id = "asset_manager_id"
    @organisation = create(:organisation)
    @model_without_assets = create(:image_data_with_no_assets)
    @asset_manager_response = {
      "id" => "http://asset-manager/assets/#{@asset_manager_id}",
      "name" => File.basename(@file),
    }
    @asset_params = {
      assetable_id: @model_without_assets.id,
      asset_variant: Asset.variants[:original],
      assetable_type: @model_without_assets.class.to_s,
    }.deep_stringify_keys
  end

  test "uploads an asset using a file object at the correct path" do
    Services.asset_manager.expects(:create_asset).with { |args|
      args[:file].path == @file.path
    }.returns(@asset_manager_response)

    @worker.perform(@file.path, @asset_params)
  end

  test "removes the local temp file after the file has been successfully uploaded" do
    Services.asset_manager.stubs(:create_asset).returns(@asset_manager_response)

    @worker.perform(@file.path, @asset_params)
    assert_not File.exist?(@file.path)
  end

  test "removes the local temp directory after the file has been successfully uploaded" do
    Services.asset_manager.stubs(:create_asset).returns(@asset_manager_response)

    @worker.perform(@file.path, @asset_params)
    assert_not Dir.exist?(File.dirname(@file))
  end

  test "doesn't run if the file is missing (e.g. job ran twice)" do
    path = @file.path
    FileUtils.rm(@file)

    Services.asset_manager.expects(:create_asset).never

    @worker.perform(path, @asset_params)
  end

  test "stores corresponding asset_manager_id and filename for current file attachment" do
    Services.asset_manager.stubs(:create_asset).returns(@asset_manager_response)

    @worker.perform(@file.path, @asset_params)

    assert_equal 1, Asset.where(asset_manager_id: @asset_manager_id, variant: Asset.variants[:original], filename: File.basename(@file)).count
  end

  test "sends auth bypass ids to asset manager when these are passed through in the params" do
    consultation = create(:consultation)

    Services.asset_manager.expects(:create_asset).with(has_entry(auth_bypass_ids: [consultation.auth_bypass_id])).returns(@asset_manager_response)

    @worker.perform(@file.path, @asset_params, [consultation.auth_bypass_id])
  end

  test "updates existing asset of same variant if it already exists" do
    # This behaviour applies to all models that have a mount_uploader
    filename = "big-cheese.960x640.jpg"
    organisation = FactoryBot.build(
      :organisation,
      organisation_logo_type_id: OrganisationLogoType::CustomLogo.id,
      logo: upload_fixture(filename, "image/png"),
    )
    organisation.assets.build(asset_manager_id: "asset_manager_id", variant: Asset.variants[:original], filename:)
    organisation.save!

    update_asset_args = { assetable_id: organisation.id, asset_variant: Asset.variants[:original], assetable_type: organisation.class.to_s }.deep_stringify_keys
    new_asset_manager_id = "new_asset_manager_id"
    asset_manager_response_with_new_id = { "id" => "http://asset-manager/assets/#{new_asset_manager_id}", "name" => File.basename(@file) }
    Services.asset_manager.stubs(:create_asset).returns(asset_manager_response_with_new_id)

    @worker.perform(@file.path, update_asset_args)

    assets = Asset.where(assetable_id: organisation.id)
    assert_equal 1, assets.count
    assert_equal new_asset_manager_id, assets.first.asset_manager_id
  end

  test "does not run if assetable (ImageData) has been deleted" do
    @model_without_assets.delete

    Services.asset_manager.expects(:create_asset).never
    Services.publishing_api.expects(:put_content).never
    Sidekiq.logger.expects(:info).once

    @worker.perform(@file.path, @asset_params)
  end

  test "should enqueue republishing of assetable" do
    # We enqueue the republishing of all assetables that implement :republish_on_assets_ready.
    # These are all the classes that use FeaturedImageData to manage their assets, such as
    # Organisation, Worldwide Organisation, TopicalEvent, Person etc.
    organisation = create(:organisation, :with_default_news_image)
    asset_params = {
      assetable_id: organisation.default_news_image.id,
      asset_variant: Asset.variants[:original],
      assetable_type: FeaturedImageData.to_s,
    }.deep_stringify_keys

    asset_manager_response_with_new_id = { "id" => "http://asset-manager/assets/some_asset_manager_id", "name" => File.basename(@file) }
    Services.asset_manager.stubs(:create_asset).returns(asset_manager_response_with_new_id)

    FeaturedImageData.any_instance.expects(:republish_on_assets_ready).once

    @worker.perform(@file.path, asset_params)
  end
end
