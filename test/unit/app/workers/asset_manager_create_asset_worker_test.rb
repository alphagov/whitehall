require "test_helper"

class AssetManagerCreateAssetWorkerTest < ActiveSupport::TestCase
  setup do
    @file = Tempfile.new("asset", Dir.mktmpdir)
    @worker = AssetManagerCreateAssetWorker.new
    @asset_manager_id = "asset_manager_id"
    @organisation = FactoryBot.create(:organisation)
    @user = FactoryBot.create(:user, organisation: @organisation, uid: "user-uid")
    @model_id = FactoryBot.create(:attachment_data).id
    @asset_manager_response = { "id" => "http://asset-manager/assets/#{@asset_manager_id}" }
  end

  test "upload an asset using a file object at the correct path" do
    Services.asset_manager.expects(:create_asset).with { |args|
      args[:file].path == @file.path
    }.returns(@asset_manager_response)

    @worker.perform(@file.path, @model_id, Asset.variants[:original])
  end

  test "marks the asset as draft if instructed" do
    Services.asset_manager.expects(:create_asset).with(has_entry(draft: true)).returns("id" => "http://asset-manager/assets/#{@asset_manager_id}")

    @worker.perform(@file.path, @model_id, Asset.variants[:original], true)
  end

  test "removes the file after it has been successfully uploaded" do
    Services.asset_manager.stubs(:create_asset).returns("id" => "http://asset-manager/assets/#{@asset_manager_id}")

    @worker.perform(@file.path, @model_id, Asset.variants[:original])
    assert_not File.exist?(@file.path)
  end

  test "removes the directory after it has been successfully uploaded" do
    Services.asset_manager.stubs(:create_asset).returns("id" => "http://asset-manager/assets/#{@asset_manager_id}")

    @worker.perform(@file.path, @model_id, Asset.variants[:original])
    assert_not Dir.exist?(File.dirname(@file))
  end

  test "marks attachments belonging to consultations as access limited" do
    consultation = FactoryBot.create(:consultation, organisations: [@organisation], access_limited: true)
    attachment = FactoryBot.create(:file_attachment, attachable: consultation)
    attachment.attachment_data.attachable = consultation

    Services.asset_manager.expects(:create_asset).with(has_entry(access_limited: [@user.uid])).returns("id" => "http://asset-manager/assets/#{@asset_manager_id}")

    @worker.perform(@file.path, @model_id, Asset.variants[:original], true, consultation.class.to_s, consultation.id)
  end

  test "marks attachments belonging to consultation responses as access limited" do
    consultation = FactoryBot.create(:consultation, organisations: [@organisation], access_limited: true)
    response = FactoryBot.create(:consultation_outcome, consultation:)
    attachment = FactoryBot.create(:file_attachment, attachable: response)
    attachment.attachment_data.attachable = consultation

    Services.asset_manager.expects(:create_asset).with(has_entry(access_limited: [@user.uid])).returns("id" => "http://asset-manager/assets/#{@asset_manager_id}")

    @worker.perform(@file.path, @model_id, Asset.variants[:original], true, consultation.class.to_s, consultation.id)
  end

  test "does not mark attachments belonging to policy groups as access limited" do
    policy_group = FactoryBot.create(:policy_group)
    attachment = FactoryBot.create(:file_attachment, attachable: policy_group)
    attachment.attachment_data.attachable = policy_group

    Services.asset_manager.expects(:create_asset).with(Not(has_key(:access_limited))).returns("id" => "http://asset-manager/assets/#{@asset_manager_id}")

    @worker.perform(@file.path, @model_id, Asset.variants[:original], true, policy_group.class.to_s, policy_group.id)
  end

  test "sends auth bypass ids to asset manager when these are passed through in the params" do
    consultation = FactoryBot.create(:consultation)
    response = FactoryBot.create(:consultation_outcome, consultation:)
    attachment = FactoryBot.create(:file_attachment, attachable: response)
    attachment.attachment_data.attachable = consultation

    Services.asset_manager.expects(:create_asset).with(has_entry(auth_bypass_ids: [consultation.auth_bypass_id])).returns("id" => "http://asset-manager/assets/#{@asset_manager_id}")

    @worker.perform(@file.path, @model_id, Asset.variants[:original], true, consultation.class.to_s, consultation.id, [consultation.auth_bypass_id])
  end
  # end

  test "doesn't run if the file is missing (e.g. job ran twice)" do
    path = @file.path
    FileUtils.rm(@file)

    Services.asset_manager.expects(:create_asset).never

    @worker.perform(path, @model_id, Asset.variants[:original])
  end

  test "stores corresponding asset_manager_id for current file attachment" do
    Services.asset_manager.stubs(:create_asset).returns("id" => "http://asset-manager/assets/#{@asset_manager_id}")

    @worker.perform(@file.path, @model_id, Asset.variants[:original])

    assert_equal 1, Asset.where(asset_manager_id: @asset_manager_id, variant: Asset.variants[:original]).count
  end

  test "updates uploaded_to_asset_manager when :original asset variant is uploaded" do
    model_id = FactoryBot.create(:attachment_data, uploaded_to_asset_manager_at: nil).id
    Services.asset_manager.stubs(:create_asset).returns("id" => "http://asset-manager/assets/#{@asset_manager_id}")

    @worker.perform(@file.path, model_id, Asset.variants[:original])
    assert_not_nil AttachmentData.find(model_id).uploaded_to_asset_manager_at
  end

  test "updates uploaded_to_asset_manager when asset variant is uploaded is not :original" do
    model_id = FactoryBot.create(:attachment_data, uploaded_to_asset_manager_at: nil).id
    Services.asset_manager.stubs(:create_asset).returns("id" => "http://asset-manager/assets/#{@asset_manager_id}")

    @worker.perform(@file.path, model_id, Asset.variants[:thumbnail])
    assert_nil AttachmentData.find(model_id).uploaded_to_asset_manager_at
  end
end
