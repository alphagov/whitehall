require "test_helper"

class AssetManagerCreateAssetWorkerTest < ActiveSupport::TestCase
  setup do
    @file = Tempfile.new("asset", Dir.mktmpdir)
    @worker = AssetManagerCreateAssetWorker.new
    @asset_manager_id = "asset_manager_id"
    @organisation = FactoryBot.create(:organisation)
    @model = FactoryBot.create(:attachment_data)
    @model_without_assets = FactoryBot.create(:attachment_data_with_no_assets)
    @asset_args_without_assets = { assetable_id: @model_without_assets.id, asset_variant: Asset.variants[:original], assetable_type: @model_without_assets.class.to_s }.deep_stringify_keys
    @asset_manager_response = {
      "id" => "http://asset-manager/assets/#{@asset_manager_id}",
      "name" => File.basename(@file),
    }
    @asset_args = { assetable_id: @model.id, asset_variant: Asset.variants[:original], assetable_type: @model.class.to_s }.deep_stringify_keys
  end

  test "upload an asset using a file object at the correct path" do
    Services.asset_manager.expects(:create_asset).with { |args|
      args[:file].path == @file.path
    }.returns(@asset_manager_response)

    @worker.perform(@file.path, @asset_args_without_assets)
  end

  test "marks the asset as draft if instructed" do
    Services.asset_manager.expects(:create_asset).with(has_entry(draft: true)).returns(@asset_manager_response)

    @worker.perform(@file.path, @asset_args_without_assets, true)
  end

  test "removes the file after it has been successfully uploaded" do
    Services.asset_manager.stubs(:create_asset).returns(@asset_manager_response)

    @worker.perform(@file.path, @asset_args)
    assert_not File.exist?(@file.path)
  end

  test "removes the directory after it has been successfully uploaded" do
    Services.asset_manager.stubs(:create_asset).returns(@asset_manager_response)

    @worker.perform(@file.path, @asset_args)
    assert_not Dir.exist?(File.dirname(@file))
  end

  test "marks attachments belonging to consultations as access limited" do
    consultation = FactoryBot.create(:consultation, organisations: [@organisation], access_limited: true)
    attachment = FactoryBot.create(:file_attachment, attachable: consultation)
    attachment.attachment_data.attachable = consultation

    Services.asset_manager.expects(:create_asset).with(has_entry(access_limited_organisation_ids: [@organisation.content_id])).returns(@asset_manager_response)

    @worker.perform(@file.path, @asset_args_without_assets, true, consultation.class.to_s, consultation.id)
  end

  test "marks attachments belonging to consultation responses as access limited" do
    consultation = FactoryBot.create(:consultation, organisations: [@organisation], access_limited: true)
    response = FactoryBot.create(:consultation_outcome, consultation:)
    attachment = FactoryBot.create(:file_attachment, attachable: response)
    attachment.attachment_data.attachable = consultation

    Services.asset_manager.expects(:create_asset).with(has_entry(access_limited_organisation_ids: [@organisation.content_id])).returns(@asset_manager_response)

    @worker.perform(@file.path, @asset_args_without_assets, true, consultation.class.to_s, consultation.id)
  end

  test "does not mark attachments belonging to policy groups as access limited" do
    policy_group = FactoryBot.create(:policy_group)
    attachment = FactoryBot.create(:file_attachment, attachable: policy_group)
    attachment.attachment_data.attachable = policy_group

    Services.asset_manager.expects(:create_asset).with(Not(has_key(:access_limited))).returns(@asset_manager_response)

    @worker.perform(@file.path, @asset_args_without_assets, true, policy_group.class.to_s, policy_group.id)
  end

  test "sends auth bypass ids to asset manager when these are passed through in the params" do
    consultation = FactoryBot.create(:consultation)
    response = FactoryBot.create(:consultation_outcome, consultation:)
    attachment = FactoryBot.create(:file_attachment, attachable: response)
    attachment.attachment_data.attachable = consultation

    Services.asset_manager.expects(:create_asset).with(has_entry(auth_bypass_ids: [consultation.auth_bypass_id])).returns(@asset_manager_response)

    @worker.perform(@file.path, @asset_args_without_assets, true, consultation.class.to_s, consultation.id, [consultation.auth_bypass_id])
  end

  test "doesn't run if the file is missing (e.g. job ran twice)" do
    path = @file.path
    FileUtils.rm(@file)

    Services.asset_manager.expects(:create_asset).never

    @worker.perform(path, @asset_args)
  end

  test "stores corresponding asset_manager_id and filename for current file attachment" do
    Services.asset_manager.stubs(:create_asset).returns(@asset_manager_response)

    @worker.perform(@file.path, @asset_args_without_assets)

    assert_equal 1, Asset.where(asset_manager_id: @asset_manager_id, variant: Asset.variants[:original], filename: File.basename(@file)).count
  end

  test "triggers an update to asset-manager" do
    # This happens via the edition services coordinator,
    # for the "update_draft" event triggered by the call to draft_updater.

    consultation = FactoryBot.create(:consultation)
    Services.asset_manager.stubs(:create_asset).returns(@asset_manager_response)

    ServiceListeners::AttachmentUpdater.expects(:call).with(attachable: consultation).once

    @worker.perform(@file.path, @asset_args, true, consultation.class.to_s, consultation.id)

    PublishingApiDraftUpdateWorker.drain
  end

  test "triggers an update to asset-manager for policy group" do
    policy_group = create(:policy_group, :with_file_attachment, description: "Description")

    Services.asset_manager.stubs(:create_asset).returns(@asset_manager_response)

    AssetManagerAttachmentMetadataWorker.expects(:perform_async).with(@model.id).once

    @worker.perform(@file.path, @asset_args, true, policy_group.class.to_s, policy_group.id)
  end

  test "triggers an update to publishing api after asset has been saved" do
    consultation = FactoryBot.create(:consultation)
    Services.asset_manager.stubs(:create_asset).returns(@asset_manager_response)

    PublishingApiDraftUpdateWorker.expects(:perform_async).with(consultation.class.to_s, consultation.id)

    @worker.perform(@file.path, @asset_args, true, consultation.class.to_s, consultation.id)
  end

  test "does not trigger an update to publishing api if attachable is not an edition" do
    consultation_outcome = FactoryBot.create(:consultation_outcome)
    Services.asset_manager.stubs(:create_asset).returns(@asset_manager_response)

    Services.publishing_api.stubs(:put_content).never

    @worker.perform(@file.path, @asset_args, true, consultation_outcome.class.to_s, consultation_outcome.id)
  end

  test "updates existing asset of same variant if it already exists - for Organisations" do
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

    @worker.perform(@file.path, update_asset_args, true)

    assets = Asset.where(assetable_id: organisation.id)
    assert_equal 1, assets.count
    assert_equal new_asset_manager_id, assets.first.asset_manager_id
  end

  test "generates missing assets on retry" do
    consultation = FactoryBot.create(:consultation)
    Services.asset_manager.stubs(:create_asset).returns(@asset_manager_response)
    @model = create(:attachment_data_with_no_assets)
    @model.assets << build(:asset, assetable_id: @model.id, assetable_type: @model.class.to_s)
    @model.save!
    thumbnail_asset_args = { assetable_id: @model.id, asset_variant: Asset.variants[:thumbnail], assetable_type: @model.class.to_s }.deep_stringify_keys

    assert_difference "Asset.where(assetable_id: @model.id).count", 1 do
      @worker.perform(@file.path, thumbnail_asset_args, true, consultation.class.to_s, consultation.id)
    end
  end

  test "does not run if assetable (ImageData) has been deleted" do
    consultation = FactoryBot.create(:consultation)
    @model = FactoryBot.create(:image_data)
    @model.class.find(@model.id).delete
    asset_args = { assetable_id: @model.id, asset_variant: Asset.variants[:original], assetable_type: @model.class.to_s }.deep_stringify_keys

    Services.asset_manager.expects(:create_asset).never
    Services.publishing_api.expects(:put_content).never
    Sidekiq.logger.expects(:info).once

    @worker.perform(@file.path, asset_args, true, consultation.class.to_s, consultation.id)
  end
end
