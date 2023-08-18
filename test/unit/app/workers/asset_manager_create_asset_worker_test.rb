require "test_helper"

class AssetManagerCreateAssetWorkerTest < ActiveSupport::TestCase
  setup do
    @file = Tempfile.new("asset", Dir.mktmpdir)
    @worker = AssetManagerCreateAssetWorker.new
    @asset_manager_id = "asset_manager_id"
    @organisation = FactoryBot.create(:organisation)
    @model = FactoryBot.create(:attachment_data)
    @asset_manager_response = { "id" => "http://asset-manager/assets/#{@asset_manager_id}" }
    @asset_args = { assetable_id: @model.id, asset_variant: Asset.variants[:original], assetable_type: @model.class.to_s }.deep_stringify_keys
  end

  test "upload an asset using a file object at the correct path" do
    Services.asset_manager.expects(:create_asset).with { |args|
      args[:file].path == @file.path
    }.returns(@asset_manager_response)

    @worker.perform(@file.path, @asset_args)
  end

  test "marks the asset as draft if instructed" do
    Services.asset_manager.expects(:create_asset).with(has_entry(draft: true)).returns(@asset_manager_response)

    @worker.perform(@file.path, @asset_args, true)
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

    @worker.perform(@file.path, @asset_args, true, consultation.class.to_s, consultation.id)
  end

  test "marks attachments belonging to consultation responses as access limited" do
    consultation = FactoryBot.create(:consultation, organisations: [@organisation], access_limited: true)
    response = FactoryBot.create(:consultation_outcome, consultation:)
    attachment = FactoryBot.create(:file_attachment, attachable: response)
    attachment.attachment_data.attachable = consultation

    Services.asset_manager.expects(:create_asset).with(has_entry(access_limited_organisation_ids: [@organisation.content_id])).returns(@asset_manager_response)

    @worker.perform(@file.path, @asset_args, true, consultation.class.to_s, consultation.id)
  end

  test "does not mark attachments belonging to policy groups as access limited" do
    policy_group = FactoryBot.create(:policy_group)
    attachment = FactoryBot.create(:file_attachment, attachable: policy_group)
    attachment.attachment_data.attachable = policy_group

    Services.asset_manager.expects(:create_asset).with(Not(has_key(:access_limited))).returns(@asset_manager_response)

    @worker.perform(@file.path, @asset_args, true, policy_group.class.to_s, policy_group.id)
  end

  test "sends auth bypass ids to asset manager when these are passed through in the params" do
    consultation = FactoryBot.create(:consultation)
    response = FactoryBot.create(:consultation_outcome, consultation:)
    attachment = FactoryBot.create(:file_attachment, attachable: response)
    attachment.attachment_data.attachable = consultation

    Services.asset_manager.expects(:create_asset).with(has_entry(auth_bypass_ids: [consultation.auth_bypass_id])).returns(@asset_manager_response)

    @worker.perform(@file.path, @asset_args, true, consultation.class.to_s, consultation.id, [consultation.auth_bypass_id])
  end

  test "doesn't run if the file is missing (e.g. job ran twice)" do
    path = @file.path
    FileUtils.rm(@file)

    Services.asset_manager.expects(:create_asset).never

    @worker.perform(path, @asset_args)
  end

  test "stores corresponding asset_manager_id for current file attachment" do
    Services.asset_manager.stubs(:create_asset).returns(@asset_manager_response)

    @worker.perform(@file.path, @asset_args)

    assert_equal 1, Asset.where(asset_manager_id: @asset_manager_id, variant: Asset.variants[:original]).count
  end

  test "updates uploaded_to_asset_manager for :original asset variant" do
    @model.uploaded_to_asset_manager_at = nil
    @model.save!
    Services.asset_manager.stubs(:create_asset).returns(@asset_manager_response)

    @worker.perform(@file.path, @asset_args)

    assert_not_nil AttachmentData.find(@model.id).uploaded_to_asset_manager_at
  end

  test "does not update uploaded_to_asset_manager when asset variant is not :original" do
    @model.uploaded_to_asset_manager_at = nil
    @model.save!
    @asset_args["asset_variant"] = Asset.variants[:thumbnail]
    Services.asset_manager.stubs(:create_asset).returns(@asset_manager_response)

    @worker.perform(@file.path, @asset_args)

    assert_nil AttachmentData.find(@model.id).uploaded_to_asset_manager_at
  end
end
