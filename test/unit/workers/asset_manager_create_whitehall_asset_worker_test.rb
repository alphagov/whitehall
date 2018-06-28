require 'test_helper'

class AssetManagerCreateWhitehallAssetWorkerTest < ActiveSupport::TestCase
  setup do
    @file = Tempfile.new('asset', Dir.mktmpdir)
    @legacy_url_path = 'legacy-url-path'
    @worker = AssetManagerCreateWhitehallAssetWorker.new
  end

  test 'creates a whitehall asset using a file object at the correct path' do
    Services.asset_manager.expects(:create_whitehall_asset).with do |args|
      args[:file].path == @file.path
    end

    @worker.perform(@file.path, @legacy_url_path)
  end

  test 'creates a whitehall asset using the legacy_url_path passed to the worker' do
    Services.asset_manager.expects(:create_whitehall_asset).with(has_entry(legacy_url_path: @legacy_url_path))

    @worker.perform(@file.path, @legacy_url_path)
  end

  test 'does not mark the asset as draft by default' do
    Services.asset_manager.expects(:create_whitehall_asset).with(Not(has_key(:draft)))

    @worker.perform(@file.path, @legacy_url_path)
  end

  test 'marks the asset as draft if instructed' do
    Services.asset_manager.expects(:create_whitehall_asset).with(has_entry(draft: true))

    @worker.perform(@file.path, @legacy_url_path, true)
  end

  test 'removes the file after it has been successfully uploaded' do
    @worker.perform(@file.path, @legacy_url_path)
    refute File.exist?(@file.path)
  end

  test 'removes the directory after it has been successfully uploaded' do
    @worker.perform(@file.path, @legacy_url_path)
    refute Dir.exist?(File.dirname(@file))
  end

  test 'marks attachments belonging to consultations as access limited' do
    organisation = FactoryBot.create(:organisation)
    user = FactoryBot.create(:user, organisation: organisation, uid: 'user-uid')
    consultation = FactoryBot.create(:consultation, organisations: [organisation], access_limited: true)
    attachment = FactoryBot.create(:file_attachment, attachable: consultation)
    attachment.attachment_data.attachable = consultation

    Services.asset_manager.expects(:create_whitehall_asset).with(has_entry(access_limited: [user.uid]))

    @worker.perform(@file.path, @legacy_url_path, true, consultation.class.to_s, consultation.id)
  end

  test 'marks attachments belonging to consultation responses as access limited' do
    organisation = FactoryBot.create(:organisation)
    user = FactoryBot.create(:user, organisation: organisation, uid: 'user-uid')
    consultation = FactoryBot.create(:consultation, organisations: [organisation], access_limited: true)
    response = FactoryBot.create(:consultation_outcome, consultation: consultation)
    attachment = FactoryBot.create(:file_attachment, attachable: response)
    attachment.attachment_data.attachable = consultation

    Services.asset_manager.expects(:create_whitehall_asset).with(has_entry(access_limited: [user.uid]))

    @worker.perform(@file.path, @legacy_url_path, true, consultation.class.to_s, consultation.id)
  end

  test 'does not mark attachments belonging to policy groups as access limited' do
    organisation = FactoryBot.create(:organisation)
    FactoryBot.create(:user, organisation: organisation, uid: 'user-uid')
    policy_group = FactoryBot.create(:policy_group)
    attachment = FactoryBot.create(:file_attachment, attachable: policy_group)
    attachment.attachment_data.attachable = policy_group

    Services.asset_manager.expects(:create_whitehall_asset).with(Not(has_key(:access_limited)))

    @worker.perform(@file.path, @legacy_url_path, true, policy_group.class.to_s, policy_group.id)
  end

  test "doesn't run if the file is missing (e.g. job ran twice)" do
    path = @file.path
    FileUtils.rm(@file)

    Services.asset_manager.expects(:create_whitehall_asset).never

    @worker.perform(path, @legacy_url_path)
  end
end
