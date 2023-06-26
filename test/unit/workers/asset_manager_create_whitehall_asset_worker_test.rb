require "test_helper"

class AssetManagerCreateWhitehallAssetWorkerTest < ActiveSupport::TestCase
  setup do
    @file = Tempfile.new("asset", Dir.mktmpdir)
    @legacy_url_path = "legacy-url-path"
    @worker = AssetManagerCreateWhitehallAssetWorker.new
    @asset_manager_id = "asset_manager_id"
  end

  test "creates a whitehall asset using a file object at the correct path" do
    Services.asset_manager.expects(:create_whitehall_asset).with do |args|
      args[:file].path == @file.path
    end

    @worker.perform(@file.path, @legacy_url_path)
  end

  test "creates a whitehall asset using the legacy_url_path passed to the worker" do
    Services.asset_manager.expects(:create_whitehall_asset).with(has_entry(legacy_url_path: @legacy_url_path))

    @worker.perform(@file.path, @legacy_url_path)
  end

  test "does not mark the asset as draft by default" do
    Services.asset_manager.expects(:create_whitehall_asset).with(Not(has_key(:draft)))

    @worker.perform(@file.path, @legacy_url_path)
  end

  test "marks the asset as draft if instructed" do
    Services.asset_manager.expects(:create_whitehall_asset).with(has_entry(draft: true))

    @worker.perform(@file.path, @legacy_url_path, nil, nil, true)
  end

  test "removes the file after it has been successfully uploaded" do
    @worker.perform(@file.path, @legacy_url_path)
    assert_not File.exist?(@file.path)
  end

  test "removes the directory after it has been successfully uploaded" do
    @worker.perform(@file.path, @legacy_url_path)
    assert_not Dir.exist?(File.dirname(@file))
  end

  test "marks attachments belonging to consultations as access limited" do
    organisation = FactoryBot.create(:organisation)
    user = FactoryBot.create(:user, organisation:, uid: "user-uid")
    consultation = FactoryBot.create(:consultation, organisations: [organisation], access_limited: true)
    attachment = FactoryBot.create(:file_attachment, attachable: consultation)
    attachment.attachment_data.attachable = consultation

    Services.asset_manager.expects(:create_whitehall_asset).with(has_entry(access_limited: [user.uid]))

    @worker.perform(@file.path, @legacy_url_path, nil, nil, true, consultation.class.to_s, consultation.id)
  end

  test "marks attachments belonging to consultation responses as access limited" do
    organisation = FactoryBot.create(:organisation)
    user = FactoryBot.create(:user, organisation:, uid: "user-uid")
    consultation = FactoryBot.create(:consultation, organisations: [organisation], access_limited: true)
    response = FactoryBot.create(:consultation_outcome, consultation:)
    attachment = FactoryBot.create(:file_attachment, attachable: response)
    attachment.attachment_data.attachable = consultation

    Services.asset_manager.expects(:create_whitehall_asset).with(has_entry(access_limited: [user.uid]))

    @worker.perform(@file.path, @legacy_url_path, nil, nil, true, consultation.class.to_s, consultation.id)
  end

  test "does not mark attachments belonging to policy groups as access limited" do
    organisation = FactoryBot.create(:organisation)
    FactoryBot.create(:user, organisation:, uid: "user-uid")
    policy_group = FactoryBot.create(:policy_group)
    attachment = FactoryBot.create(:file_attachment, attachable: policy_group)
    attachment.attachment_data.attachable = policy_group

    Services.asset_manager.expects(:create_whitehall_asset).with(Not(has_key(:access_limited)))

    @worker.perform(@file.path, @legacy_url_path, nil, nil, true, policy_group.class.to_s, policy_group.id)
  end

  test "sends auth bypass ids to asset manager when these are passed through in the params" do
    consultation = FactoryBot.create(:consultation)
    response = FactoryBot.create(:consultation_outcome, consultation:)
    attachment = FactoryBot.create(:file_attachment, attachable: response)
    attachment.attachment_data.attachable = consultation

    Services.asset_manager.expects(:create_whitehall_asset).with(has_entry(auth_bypass_ids: [consultation.auth_bypass_id]))

    @worker.perform(@file.path, @legacy_url_path, nil, nil, true, consultation.class.to_s, consultation.id, [consultation.auth_bypass_id])
  end

  test "doesn't run if the file is missing (e.g. job ran twice)" do
    path = @file.path
    FileUtils.rm(@file)

    Services.asset_manager.expects(:create_whitehall_asset).never

    @worker.perform(path, @legacy_url_path)
  end

  test "stores corresponding asset_manager_id for current file attachment" do
    model_id = FactoryBot.create(:attachment_data).id
    version = Asset.versions[:original]
    Services.asset_manager.stubs(:create_whitehall_asset).returns("id" => "http://asset-manager/assets/#{@asset_manager_id}")

    @worker.perform(@file.path, @legacy_url_path, model_id, version)

    assert_equal Asset.where(asset_manager_id: @asset_manager_id, version:).count, 1
  end

  test "does not store asset_manager_id if there if no values provided for model_id or version" do
    @worker.perform(@file.path, @legacy_url_path)

    assert_equal Asset.where(asset_manager_id: @asset_manager_id).count, 0
  end
end
