require "test_helper"

class AssetManagerCreateAttachmentAssetWorkerTest < ActiveSupport::TestCase
  setup do
    @file = Tempfile.new("asset", Dir.mktmpdir)
    @worker = AssetManagerCreateAttachmentAssetWorker.new
    @asset_manager_id = "asset_manager_id"
    @organisation = create(:organisation)
    @edition = create(:draft_publication)
    @model_without_assets = create(:attachment_data_with_no_assets, attachable: @edition)
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

    @worker.perform(@file.path, @asset_params, @edition.class.to_s, @edition.id, false)
  end

  test "marks the asset as draft if instructed" do
    Services.asset_manager.expects(:create_asset).with(has_entry(draft: true)).returns(@asset_manager_response)

    @worker.perform(@file.path, @asset_params, @edition.class.to_s, @edition.id, true)
  end

  test "removes the local temp file after the file has been successfully uploaded" do
    Services.asset_manager.stubs(:create_asset).returns(@asset_manager_response)

    @worker.perform(@file.path, @asset_params, @edition.class.to_s, @edition.id, false)
    assert_not File.exist?(@file.path)
  end

  test "removes the local temp directory after the file has been successfully uploaded" do
    Services.asset_manager.stubs(:create_asset).returns(@asset_manager_response)

    @worker.perform(@file.path, @asset_params, @edition.class.to_s, @edition.id, false)
    assert_not Dir.exist?(File.dirname(@file))
  end

  test "marks attachments belonging to consultations as access limited" do
    consultation = create(:consultation, organisations: [@organisation], access_limited: true)
    attachment = create(:file_attachment, attachable: consultation)
    attachment.attachment_data.attachable = consultation

    Services.asset_manager.expects(:create_asset).with(has_entry(access_limited_organisation_ids: [@organisation.content_id])).returns(@asset_manager_response)

    @worker.perform(@file.path, @asset_params, consultation.class.to_s, consultation.id, true)
  end

  test "marks attachments belonging to consultation responses as access limited" do
    consultation = create(:consultation, organisations: [@organisation], access_limited: true)
    response = create(:consultation_outcome, consultation:)
    attachment = create(:file_attachment, attachable: response)
    attachment.attachment_data.attachable = consultation

    Services.asset_manager.expects(:create_asset).with(has_entry(access_limited_organisation_ids: [@organisation.content_id])).returns(@asset_manager_response)

    @worker.perform(@file.path, @asset_params, consultation.class.to_s, consultation.id, true)
  end

  test "does not mark attachments belonging to policy groups as access limited" do
    policy_group = create(:policy_group)
    attachment = create(:file_attachment, attachable: policy_group)
    attachment.attachment_data.attachable = policy_group

    Services.asset_manager.expects(:create_asset).with(Not(has_key(:access_limited))).returns(@asset_manager_response)

    @worker.perform(@file.path, @asset_params, policy_group.class.to_s, policy_group.id, true)
  end

  test "sends auth bypass ids to asset manager when these are passed through in the params" do
    consultation = create(:consultation)
    response = create(:consultation_outcome, consultation:)
    attachment = create(:file_attachment, attachable: response)
    attachment.attachment_data.attachable = consultation

    Services.asset_manager.expects(:create_asset).with(has_entry(auth_bypass_ids: [consultation.auth_bypass_id])).returns(@asset_manager_response)

    @worker.perform(@file.path, @asset_params, consultation.class.to_s, consultation.id, true, [consultation.auth_bypass_id])
  end

  test "doesn't run if the file is missing (e.g. job ran twice)" do
    path = @file.path
    FileUtils.rm(@file)

    Services.asset_manager.expects(:create_asset).never

    @worker.perform(path, @asset_params, @edition.class.to_s, @edition.id)
  end

  test "stores corresponding asset_manager_id and filename for current file attachment" do
    Services.asset_manager.stubs(:create_asset).returns(@asset_manager_response)

    @worker.perform(@file.path, @asset_params, @edition.class.to_s, @edition.id)

    assert_equal 1, Asset.where(asset_manager_id: @asset_manager_id, variant: Asset.variants[:original], filename: File.basename(@file)).count
  end

  test "triggers an update to asset-manager for any edition based document-type" do
    # This happens via the edition services coordinator,
    # for the "update_draft" event triggered by the call to draft_updater.

    consultation = create(:consultation)
    Services.asset_manager.stubs(:create_asset).returns(@asset_manager_response)

    ServiceListeners::AttachmentUpdater.expects(:call).with(attachable: consultation).once

    @worker.perform(@file.path, @asset_params, consultation.class.to_s, consultation.id, true)

    PublishingApiDraftUpdateWorker.drain
  end

  test "triggers an update to asset-manager for policy group" do
    policy_group = create(:policy_group, :with_file_attachment, description: "Description")

    Services.asset_manager.stubs(:create_asset).returns(@asset_manager_response)

    AssetManagerAttachmentMetadataWorker.expects(:perform_async).with(@model_without_assets.id).once

    @worker.perform(@file.path, @asset_params, policy_group.class.to_s, policy_group.id, true)
  end

  test "triggers an update to publishing api after asset has been saved" do
    consultation = create(:consultation)
    Services.asset_manager.stubs(:create_asset).returns(@asset_manager_response)

    PublishingApiDraftUpdateWorker.expects(:perform_async).with(consultation.class.to_s, consultation.id)

    @worker.perform(@file.path, @asset_params, consultation.class.to_s, consultation.id, true)
  end

  test "does not trigger an update to publishing api if attachable is not an edition" do
    consultation_outcome = create(:consultation_outcome)
    Services.asset_manager.stubs(:create_asset).returns(@asset_manager_response)

    Services.publishing_api.stubs(:put_content).never

    @worker.perform(@file.path, @asset_params, consultation_outcome.class.to_s, consultation_outcome.id, true)
  end

  test "updates existing asset of same variant if it already exists" do
    # This behaviour applies to all models that have a mount_uploader
    consultation = create(:consultation, organisations: [@organisation], access_limited: true)
    attachment = create(:file_attachment, attachable: consultation)
    attachment.attachment_data.attachable = consultation

    new_asset_manager_id = "new_asset_manager_id"
    asset_manager_response_with_new_id = { "id" => "http://asset-manager/assets/#{new_asset_manager_id}", "name" => File.basename(@file) }
    Services.asset_manager.stubs(:create_asset).returns(asset_manager_response_with_new_id)

    update_asset_args = { assetable_id: attachment.attachment_data.id, asset_variant: Asset.variants[:original], assetable_type: attachment.attachment_data.class.to_s }.deep_stringify_keys
    @worker.perform(@file.path, update_asset_args, @edition.class.to_s, @edition.id, true)

    assets = Asset.where(assetable_id: attachment.attachment_data.id, assetable_type: attachment.attachment_data.class.to_s, variant: Asset.variants[:original])
    assert_equal 1, assets.count
    assert_equal new_asset_manager_id, assets.first.asset_manager_id
  end

  test "does not run if assetable has been deleted" do
    consultation = create(:consultation)
    @model_without_assets.delete

    Services.asset_manager.expects(:create_asset).never
    Services.publishing_api.expects(:put_content).never
    Sidekiq.logger.expects(:info).once

    @worker.perform(@file.path, @asset_params, consultation.class.to_s, consultation.id, true)
  end

  test "should not process the file if the attachable has been deleted" do
    consultation = create(:consultation, organisations: [@organisation], access_limited: true)
    consultation.delete
    consultation.save!(validate: false)

    Sidekiq.logger.expects(:info).once
    Services.asset_manager.expects(:create_asset).never

    @worker.perform(@file.path, @asset_params, consultation.class.to_s, consultation.id, true)
  end
end
