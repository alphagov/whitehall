require "test_helper"

class MigrateAssetsToAssetManagerTest < ActiveSupport::TestCase
  setup do
    organisation_logo_dir = File.join(Whitehall.clean_uploads_root, 'system', 'uploads', 'organisation', 'logo', '1')
    FileUtils.mkdir_p(organisation_logo_dir)

    @organisation_logo_path = File.join(organisation_logo_dir, 'logo.jpg')
    dummy_asset_path = Rails.root.join('test', 'fixtures', 'images', '960x640_jpeg.jpg')
    FileUtils.cp(dummy_asset_path, @organisation_logo_path)

    @organisation_logo_file = File.open(@organisation_logo_path)

    @subject = MigrateAssetsToAssetManager.new
  end

  test 'it calls create_whitehall_asset for each file in the list' do
    Services.asset_manager.expects(:create_whitehall_asset).with(has_entry(:file, responds_with(:path, @organisation_logo_path)))

    @subject.perform
  end

  test 'it calls create_whitehall_asset with the legacy file path' do
    Services.asset_manager.expects(:create_whitehall_asset).with(
      has_entry(:legacy_url_path, '/government/uploads/system/uploads/organisation/logo/1/logo.jpg')
    )

    @subject.perform
  end

  test 'it calls create_whitehall_asset with the legacy last modified time' do
    expected_last_modified = File.stat(@organisation_logo_file.path).mtime

    Services.asset_manager.expects(:create_whitehall_asset).with(
      has_entry(:legacy_last_modified, expected_last_modified)
    )

    @subject.perform
  end
end

class OrganisationLogoFilesTest < ActiveSupport::TestCase
  setup do
    organisation_logo_dir = File.join(Whitehall.clean_uploads_root, 'system', 'uploads', 'organisation', 'logo', '1')
    other_asset_dir = File.join(Whitehall.clean_uploads_root, 'system', 'uploads', 'other')

    FileUtils.mkdir_p(organisation_logo_dir)
    FileUtils.mkdir_p(other_asset_dir)

    organisation_logo_path = File.join(organisation_logo_dir, 'logo.jpg')
    other_asset_path = File.join(other_asset_dir, 'other_asset.png')
    dummy_asset_path = Rails.root.join('test', 'fixtures', 'images', '960x640_jpeg.jpg')

    FileUtils.cp(dummy_asset_path, organisation_logo_path)
    FileUtils.cp(dummy_asset_path, other_asset_path)

    @organisation_logo = File.open(organisation_logo_path)
    @other_asset = File.open(other_asset_path)

    @subject = MigrateAssetsToAssetManager::OrganisationLogoFiles.new
  end

  test 'delegates each to files' do
    assert @subject.respond_to?(:each)
  end

  test '#files includes only organistation logos' do
    assert_equal 1, @subject.files.size
  end

  test '#files does not includes directories' do
    @subject.files.each do |file|
      refute File.directory?(file)
    end
  end
end
